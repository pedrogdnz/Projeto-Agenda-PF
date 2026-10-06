<h1 align="center">📸 Agenda do Estúdio de Fotos</h1>

<div align="center">
<img width="851" height="315" alt="Banner do projeto" src="https://github.com/user-attachments/assets/716a9454-e3ae-432b-96ea-34095902ee00" />
</div>

<br>

<div align="center">

![Status](http://img.shields.io/static/v1?label=STATUS&message=EM%20DESENVOLVIMENTO&color=GREEN&style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-3.41.9-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)

</div>

<br>

## Sobre

Aplicativo mobile para reserva de horários do estúdio de fotografia do curso de **Processos Fotográficos (PF)** do **IFPR – Campus Curitiba**. Alunos do integrado e do subsequente consultam o calendário e reservam horários; administradores configuram o ano letivo e acompanham as reservas.

## Funcionalidades

**Aluno**
- Cadastro e login por e-mail/senha ou conta Google institucional
- Reserva de horário com escolha de data, fundo (branco ou preto) e horário
- Consulta e cancelamento das próprias reservas
- Perfil com foto

**Administrador**
- Configuração do ano letivo (férias, feriados e horários de atendimento)
- Gestão de alunos, administradores e reservas

## Tecnologias

- Flutter 3.41.9 e Dart 3.11.5
- Firebase Authentication e Cloud Firestore
- Arquitetura MVVM

## Como executar

```bash
git clone <url-do-repositorio>
cd agendapf
flutter pub get
flutterfire configure
flutter run
```

É necessário ter o Flutter instalado e um projeto no Firebase com Authentication e Firestore habilitados.

## Autores

- Pedro Guerreiro Diniz
- Shauane Eliza Santos da Cunha
- Thiago Vinícius Braga Aksenen
