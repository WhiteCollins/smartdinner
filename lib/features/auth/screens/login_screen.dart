import 'package:flutter/material.dart';
import '../../../core/services/supabase_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabaseService = SupabaseService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 800;
          final isTablet =
              constraints.maxWidth > 600 && constraints.maxWidth <= 800;
          final isMobile = constraints.maxWidth <= 600;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Theme.of(context).primaryColor.withOpacity(0.05),
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWideScreen ? 32 : 16,
                    vertical: 16,
                  ),
                  child: _buildLoginContent(
                    context,
                    isWideScreen,
                    isTablet,
                    isMobile,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginContent(
    BuildContext context,
    bool isWideScreen,
    bool isTablet,
    bool isMobile,
  ) {
    final maxWidth = isWideScreen
        ? 400.0
        : (isTablet ? 350.0 : double.infinity);

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Card(
        elevation: isWideScreen ? 8 : 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(isWideScreen ? 32 : (isTablet ? 24 : 20)),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context, isWideScreen, isTablet, isMobile),
                SizedBox(height: isWideScreen ? 32 : 24),
                _buildTestUsersCard(context, isMobile),
                SizedBox(height: isWideScreen ? 24 : 16),
                _buildFormFields(context, isMobile),
                SizedBox(height: isWideScreen ? 32 : 24),
                _buildButtons(context, isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isWideScreen,
    bool isTablet,
    bool isMobile,
  ) {
    final logoSize = isWideScreen ? 80.0 : (isTablet ? 70.0 : 60.0);
    final titleSize = isWideScreen ? 28.0 : (isTablet ? 24.0 : 20.0);

    return Column(
      children: [
        Hero(
          tag: 'logo',
          child: Container(
            height: logoSize,
            width: logoSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.restaurant,
              size: logoSize * 0.5,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 16),
        Text(
          'SmartDinner',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Bienvenido de vuelta',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
            fontSize: isMobile ? 14 : 16,
          ),
        ),
      ],
    );
  }

  Widget _buildTestUsersCard(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      child: Card(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).primaryColor,
                    size: isMobile ? 18 : 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Usuarios de Prueba',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              _buildCredentialRow('admin@smartdinner.com', '123456', isMobile),
              SizedBox(height: 4),
              _buildCredentialRow(
                'usuario@smartdinner.com',
                'password',
                isMobile,
                isSecondary: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialRow(
    String email,
    String password,
    bool isMobile, {
    bool isSecondary = false,
  }) {
    final textSize = isMobile ? 12.0 : 13.0;
    final color = isSecondary ? Colors.grey[600] : Colors.grey[800];

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            email,
            style: TextStyle(fontSize: textSize, color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8),
        Text('/', style: TextStyle(color: color)),
        SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: Text(
            password,
            style: TextStyle(fontSize: textSize, color: color),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields(BuildContext context, bool isMobile) {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isMobile ? 12 : 16,
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingrese su email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Ingrese un email válido';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: Icon(Icons.lock_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isMobile ? 12 : 16,
            ),
          ),
          obscureText: true,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) {
            if (_formKey.currentState!.validate()) {
              _performLogin();
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingrese su contraseña';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context, bool isMobile) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: isMobile ? 48 : 52,
          child: ElevatedButton(
            onPressed: _isLoading
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      _performLogin();
                    }
                  },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 16),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/register');
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isMobile ? 14 : 16,
              ),
              children: [
                TextSpan(text: '¿No tienes cuenta? '),
                TextSpan(
                  text: 'Regístrate',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _performLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Intentar iniciar sesión con Supabase
      final response = await _supabaseService.signInWithEmail(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Login exitoso
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Bienvenido a SmartDinner!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navegar a la pantalla principal
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      // Login fallido
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al iniciar sesión: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
