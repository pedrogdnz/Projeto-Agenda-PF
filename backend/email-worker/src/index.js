
import { jwtVerify, createRemoteJWKSet } from "jose";
import { WorkerMailer } from "@workermailer/smtp";

const firebaseKeys = createRemoteJWKSet(
  new URL(
    "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com"
  )
);

const PROJECT_ID = "agendapf";

async function verifyFirebaseToken(token) {
  const { payload } = await jwtVerify(token, firebaseKeys, {
    issuer: `https://securetoken.google.com/${PROJECT_ID}`,
    audience: PROJECT_ID,
  });

  if (!payload.sub || !payload.exp || !payload.iat) {
    throw new Error("Token Firebase inválido.");
  }

  if (payload.sub !== payload.user_id) {
    throw new Error("Identidade do usuário inválida.");
  }

  return payload;
}

function escapeHtml(value) {
  return String(value ?? "").replace(/[&<>"']/g, (char) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#39;",
  })[char]);
}

function formatarData(data) {
  if (!data) return "Não informada";

  const partes = data.split("-");
  if (partes.length !== 3) return data;

  return `${partes[2]}/${partes[1]}/${partes[0]}`;
}

function montarEmail(tipo, dados, destinatario) {
  const mensagens = {
    criacao: {
      aluno: {
        assunto: "Reserva confirmada - Agenda PF",
        titulo: "Sua reserva foi confirmada!",
        mensagem: "Sua reserva foi registrada com sucesso.",
      },
      admin: {
        assunto: "Nova reserva - Agenda PF",
        titulo: "Nova reserva realizada",
        mensagem: "Um aluno acabou de realizar uma reserva.",
      },
    },
    edicao: {
      aluno: {
        assunto: "Reserva alterada - Agenda PF",
        titulo: "Sua reserva foi alterada",
        mensagem: "O administrador atualizou os dados da sua reserva.",
      },
      admin: {
        assunto: "Edição confirmada - Agenda PF",
        titulo: "Reserva atualizada com sucesso",
        mensagem: "A alteração da reserva foi realizada.",
      },
    },
    cancelamento: {
      aluno: {
        assunto: "Reserva cancelada - Agenda PF",
        titulo: "Sua reserva foi cancelada",
        mensagem: "O cancelamento da sua reserva foi realizado.",
      },
      admin: {
        assunto: "Reserva cancelada - Agenda PF",
        titulo: "Cancelamento confirmado",
        mensagem: "Uma reserva foi removida do sistema.",
      },
    },
  };

  const mensagem = mensagens[tipo]?.[destinatario];

  if (!mensagem) {
    throw new Error("Tipo de notificação inválido.");
  }

  const aluno = escapeHtml(dados.alunoNome);
  const data = escapeHtml(formatarData(dados.data));
  const horario = escapeHtml(dados.horario);
  const fundo = escapeHtml(dados.fundo);
  const professor = escapeHtml(dados.professor);
  const descricao = escapeHtml(dados.descricao || "Não informada");

  return {
    subject: mensagem.assunto,
    html: `
      <div style="font-family: Arial, sans-serif; color: #222; max-width: 600px;">
        <h2>${mensagem.titulo}</h2>
        <p>${mensagem.mensagem}</p>
        <hr>
        <h3>Dados da reserva</h3>
        <p><strong>Aluno:</strong> ${aluno}</p>
        <p><strong>Data:</strong> ${data}</p>
        <p><strong>Horário:</strong> ${horario}</p>
        <p><strong>Fundo:</strong> ${fundo}</p>
        <p><strong>Professor:</strong> ${professor}</p>
        <p><strong>Descrição:</strong> ${descricao}</p>
        <hr>
        <p>Agenda PF</p>
      </div>
    `,
  };
}



async function enviarEmail(env, to, subject, html) {
  let mailer;

  try {
    console.log("SMTP: iniciando conexão com Gmail...");

    mailer = await WorkerMailer.connect({
      host: "smtp.gmail.com",
      port: 587,
      secure: false,
      startTls: true,
      authType: "plain",

      credentials: {
        username: env.GMAIL_USER,
        password: env.GMAIL_APP_PASSWORD,
      },

      hooks: {
        onConnect: () => {
          console.log("SMTP: conexão estabelecida com Gmail.");
        },

        onSent: (email, response) => {
          console.log(
            "SMTP: mensagem aceita:",
            email?.to,
            response
          );
        },

        onError: (email, error) => {
          console.error(
            "SMTP: erro no envio:",
            email?.to,
            String(error)
          );
        },

        onClose: (error) => {
          if (error) {
            console.error(
              "SMTP: erro ao fechar conexão:",
              String(error)
            );
          }
        },
      },
    });

    console.log("SMTP: conexão autenticada. Enviando para:", to);

    const result = await mailer.send({
      from: {
        name: "Agenda PF",
        email: env.GMAIL_USER,
      },
      to,
      subject,
      html,
    });

    console.log("SMTP: resultado do envio:", result);

    return result;

  } catch (error) {
    const detalhes = {
      name: error?.name,
      message: error?.message,
      code: error?.code,
      response: error?.response,
      responseCode: error?.responseCode,
      command: error?.command,
      cause: error?.cause
        ? {
            name: error.cause.name,
            message: error.cause.message,
            code: error.cause.code,
          }
        : undefined,
      stack: error?.stack,
    };

    console.error(
      "SMTP: DETALHES COMPLETOS DO ERRO:",
      JSON.stringify(detalhes)
    );

    console.error(
      "SMTP: ERRO ORIGINAL:",
      String(error)
    );

    throw error;

  } finally {
    if (mailer) {
      try {
        await mailer.close();
      } catch (closeError) {
        console.error(
          "SMTP: falha ao fechar conexão:",
          String(closeError)
        );
      }
    }
  }
}



export default {
  async fetch(request, env) {
    if (request.method !== "POST") {
      return Response.json(
        { error: "Método não permitido." },
        { status: 405 }
      );
    }

    const url = new URL(request.url);

    if (url.pathname !== "/send-notification") {
      return Response.json(
        { error: "Rota não encontrada." },
        { status: 404 }
      );
    }

    try {
      const authorization = request.headers.get("Authorization");

      if (!authorization?.startsWith("Bearer ")) {
        return Response.json(
          { error: "Token não informado." },
          { status: 401 }
        );
      }

      const token = authorization.substring(7);
      const user = await verifyFirebaseToken(token);

      const dados = await request.json();

      const {
        tipo,
        origem,
        alunoId,
        alunoNome,
        alunoEmail,
        data,
        horario,
        fundo,
        professor,
        descricao,
      } = dados;

      if (!["criacao", "edicao", "cancelamento"].includes(tipo)) {
        return Response.json(
          { error: "Tipo de notificação inválido." },
          { status: 400 }
        );
      }

      if (
  !env.GMAIL_USER ||
  !env.GMAIL_APP_PASSWORD ||
  !env.ADMIN_EMAIL
) {
        return Response.json(
          { error: "Origem inválida." },
          { status: 400 }
        );
      }

      const adminUids = (env.ADMIN_UIDS || "")
        .split(",")
        .map((uid) => uid.trim())
        .filter(Boolean);

      const ehAdmin = adminUids.includes(user.user_id);
      const ehAluno = user.user_id === alunoId;

      // Criação: somente o próprio aluno.
      if (tipo === "criacao" && (origem !== "aluno" || !ehAluno)) {
        return Response.json(
          { error: "Operação não autorizada." },
          { status: 403 }
        );
      }

      // Edição: somente administrador.
      if (tipo === "edicao" && (origem !== "admin" || !ehAdmin)) {
        return Response.json(
          { error: "Apenas administradores podem editar reservas." },
          { status: 403 }
        );
      }

      // Cancelamento: aluno dono da reserva ou administrador autorizado.
      if (tipo === "cancelamento") {
        const autorizado =
          (origem === "aluno" && ehAluno) ||
          (origem === "admin" && ehAdmin);

        if (!autorizado) {
          return Response.json(
            { error: "Operação não autorizada." },
            { status: 403 }
          );
        }
      }

      if (!alunoId || !alunoNome || !data || !horario) {
        return Response.json(
          { error: "Dados da reserva incompletos." },
          { status: 400 }
        );
      }

      // Nas operações do aluno, o destinatário é o e-mail
      // verificado pelo próprio token Firebase.
      const emailDoAluno = origem === "aluno"
        ? user.email
        : alunoEmail;

      if (!emailDoAluno) {
        return Response.json(
          { error: "E-mail do aluno não encontrado." },
          { status: 400 }
        );
      }

      const dadosEmail = {
        alunoNome,
        data,
        horario,
        fundo,
        professor,
        descricao,
      };

      const emailAluno = montarEmail(tipo, dadosEmail, "aluno");
      const emailAdmin = montarEmail(tipo, dadosEmail, "admin");

      // Um envio não impede a tentativa do outro.
      const resultados = await Promise.allSettled([
        enviarEmail(
          env,
          emailDoAluno,
          emailAluno.subject,
          emailAluno.html
        ),
        enviarEmail(
          env,
          env.ADMIN_EMAIL,
          emailAdmin.subject,
          emailAdmin.html
        ),
      ]);

      const alunoEnviado = resultados[0].status === "fulfilled";
      const adminEnviado = resultados[1].status === "fulfilled";

      if (!alunoEnviado) {
        console.error("Falha no e-mail do aluno:", resultados[0].reason);
      }

      if (!adminEnviado) {
        console.error("Falha no e-mail do administrador:", resultados[1].reason);
      }

      return Response.json({
        success: alunoEnviado && adminEnviado,
        aluno: alunoEnviado ? "enviado" : "falhou",
        admin: adminEnviado ? "enviado" : "falhou",
      });

    } catch (error) {
      console.error("Erro no Worker:", error);

      return Response.json(
        { error: "Falha no processamento da notificação." },
        { status: 500 }
      );
    }
  },
};
