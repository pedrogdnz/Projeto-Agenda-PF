import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.height / 100;
    return Scaffold(
    backgroundColor: Colors.black,
     body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Image(image: AssetImage("images/ifpr_logo.png")),
              ),
            ),
            Container(
            height: size * 80,
            width: size * 100,
            decoration: BoxDecoration(borderRadius: BorderRadius.only(topRight: Radius.circular(80)), color: Colors.white,),
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Registre-se", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),),
                  
                  Row(
                    children: [
                      Text('Já tem uma conta?'),
                      TextButton(onPressed: (){}, child: Text('Login', style: TextStyle(fontWeight: FontWeight.bold),)),
                    ],
                  ),
                  
                  SizedBox(
                    height: 20,
                  ),
                  
                  Text("Nome:", style: TextStyle(fontWeight: FontWeight.bold),),
                  TextFormField(
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                  
                  SizedBox(
                    height: 20,
                  ),
                  
                  Text("E-mail:", style: TextStyle(fontWeight: FontWeight.bold),),
                  TextFormField(
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                  
                  SizedBox(
                    height: 20,
                  ),
                  
                  Text("Senha:", style: TextStyle(fontWeight: FontWeight.bold),),
                  TextFormField(
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                  
                  SizedBox(
                    height: 20,
                  ),
                  
                  Text("Confirme sua senha:", style: TextStyle(fontWeight: FontWeight.bold),),
                  TextFormField(
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                  
                  SizedBox(
                    height: 20,
                  ),
              
                  Row(
                    children: [
                      Expanded(child: TextButton(
                        
                        onPressed: (){},
                        child: Text("Login", style: TextStyle(fontWeight: FontWeight.bold)),
                        )),
                    ],
                  )
                ],
              ),
            )
            )
        ] 
      )
    );
  }
}

