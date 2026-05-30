import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import './home.dart';
import 'package:zynzynzynsahur/services/zynyo_service.dart';



// Stateful widget for the Login screen.
class Login extends StatefulWidget {
  final ZynyoService zynyoService;                                    // add this
  const Login({Key? key, required this.zynyoService}) : super(key: key); // add zynyoService

  @override
  State<Login> createState() => _LoginState();
}

// State class for the Login widget.
class _LoginState extends State<Login> { 
    
  // Map to store user data (if needed in the future).
  Map userData = {}; 
  
  // Key to manage the form state.
  final _formkey = GlobalKey<FormState>(); 

  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar( 
        
        // Title of the AppBar.
        title: Text('Login'), 
        
        // Background color of the AppBar.
        backgroundColor: Colors.green, 
        
        // Text color of the AppBar.
        foregroundColor: Colors.white, 
        
        // Centers the title in the AppBar.
        centerTitle: true, 
      ), 
      
      // Allows scrolling for smaller screens.
      body: SingleChildScrollView( 
        child: Column( 
          children: <Widget>[ 
            
            // Logo section at the top.
            Padding( 
              padding: const EdgeInsets.only(top: 30.0), 
              child: Center( 
                child: Container( 
                  width: 120, 
                  height: 120, 
                  decoration: BoxDecoration( 
                      
                    // Rounded corners.
                    borderRadius: BorderRadius.circular(40), 
                    
                    // Border styling.
                    border: Border.all(color: Colors.blueGrey) 
                  ), 
                  child: Image.asset(
                      
                    // Path to the logo image.
                    'images/images.png', 
                    height: 30,
                    width: 20,
                  ), 
                ), 
              ), 
            ), 
            
            // Form section for user input.
            Padding( 
              padding: EdgeInsets.symmetric(horizontal: 15), 
              child: Padding( 
                padding: const EdgeInsets.all(12.0), 
                child: Form( 
                    
                  // Associates the form with the key.
                  key: _formkey, 
                  child: Column( 
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: <Widget>[ 
                        
                      // Email input field.
                      Padding( 
                        padding: const EdgeInsets.all(12.0), 
                        child: TextFormField( 
                          validator: MultiValidator([ 
                            RequiredValidator( 
                              
                              // Validation for required field.
                              errorText: 'Enter email address'), 
                            EmailValidator( 
                                
                              // Validation for email format.
                              errorText: 'Please correct email filled'), 
                          ]), 
                          decoration: InputDecoration( 
                              
                            // Placeholder text.
                            hintText: 'Email', 
                            
                            // Label for the field.
                            labelText: 'Email', 
                            prefixIcon: Icon(
                              
                              // Email icon.
                              Icons.email, 
                            ), 
                            
                            // Error message styling.
                            errorStyle: TextStyle(fontSize: 18.0), 
                            border: OutlineInputBorder( 
                              borderSide: BorderSide(color: Colors.red), 
                              borderRadius: BorderRadius.all( 
                                  
                                // Rounded border.
                                Radius.circular(9.0)) 
                            )
                          )
                        )
                      ), 
                      
                      // Password input field.
                      Padding( 
                        padding: const EdgeInsets.all(12.0), 
                        child: TextFormField( 
                          validator: MultiValidator([ 
                            RequiredValidator( 
                                
                              // Validation for required field.
                              errorText: 'Please enter Password'), 
                            MinLengthValidator(8, 
                            
                              // Minimum length validation.
                              errorText: 'Password must be at least 8 characters'), 
                            PatternValidator(r'(?=.*?[#!@$%^&*-])', 
                            
                              // Special character validation.
                              errorText: 'Psw must have at least one special character') 
                          ]), 
                          decoration: InputDecoration( 
                            
                            // Placeholder text.
                            hintText: 'Password', 
                            
                            // Label for the field.
                            labelText: 'Password', 
                            prefixIcon: Icon( 
                                
                              // Key icon for password.
                              Icons.key, 
                              color: Colors.green, 
                            ), 
                            
                            // Error message styling.
                            errorStyle: TextStyle(fontSize: 18.0), 
                            border: OutlineInputBorder( 
                              borderSide: BorderSide(color: Colors.red),
                              
                              // Rounded border.
                              borderRadius: BorderRadius.all(Radius.circular(9.0)) 
                            ), 
                          ), 
                        ), 
                      ), 
                      
                      // Forget password text.
                      Container( 
                        margin: EdgeInsets.fromLTRB(200, 0, 0, 0), 
                        child: Text('Forget Password!'), 
                      ), 
                      
                      // Login button.
                      Padding( 
                        padding: const EdgeInsets.all(28.0), 
                        child: Container( 
                          child: ElevatedButton( 
                            child: Text( 
                              'Login', 
                              style: TextStyle( 
                                
                                // Button text styling.
                                color: Colors.white, fontSize: 22), 
                            ), 
                            onPressed: () {
                              if (_formkey.currentState!.validate()) {
                                    // Navigate to the next page
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomePage(zynyoService: widget.zynyoService,),
                                    ),
                                );
                              }
                          },
                            style: ElevatedButton.styleFrom(
                                
                              // Button background color.
                              backgroundColor: Colors.green, 
                              
                              // Button text color.
                              foregroundColor: Colors.white, 
                            )
                          ), 
                          
                          // Button width.
                          width: MediaQuery.of(context).size.width, 
                          
                          // Button height.
                          height: 50, 
                        ), 
                      ), 
                      
                      // Divider text for alternative sign-in options.
                      Center( 
                        child: Padding( 
                          padding: EdgeInsets.fromLTRB(0, 30, 0, 0), 
                          child: Center( 
                            child: Text( 
                              'Or Sign In Using!', 
                              style: TextStyle( 
                                  
                                // Text styling.
                                fontSize: 18, color: Colors.black), 
                            ), 
                          ), 
                        ), 
                      ), 
                      
                      // Social media sign-in options (Google in this case).
                      Row( 
                        mainAxisAlignment: MainAxisAlignment.center, 
                        children: [ 
                          Padding( 
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 0), 
                            child: Container( 
                              height: 40, 
                              width: 40, 
                              child: Image.asset( 
                                  
                                // Path to Google logo.
                                'images/images.png', 
                                fit: BoxFit.cover, 
                              ), 
                            ), 
                          ), 
                        ], 
                      ), 
                      // Sign-up text at the bottom.
                      Center( 
                        child: Container( 
                          padding: EdgeInsets.only(top: 50), 
                          child: Text( 
                            'SIGN UP!', 
                            style: TextStyle( 
                              fontSize: 20, 
                              
                              // Bold text.
                              fontWeight: FontWeight.w700, 
                              
                              // Text color.
                              color: Colors.lightBlue, 
                            ), 
                          ), 
                        ), 
                      ) 
                    ]), 
                )), 
              ), 
            ]), 
        
        ), 
      );
       
  
  } 
}