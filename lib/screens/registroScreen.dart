import 'package:flutter/material.dart';

class registroScreen extends StatelessWidget {
  const registroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color.fromARGB(255, 110, 31, 93);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registro',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        backgroundColor: primaryPurple,
        elevation: 0,
      ),
      // backgroundColor eliminado, ahora usamos imagen en el body
      body: Stack(
        children: [
          // Fondo con imagen
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://ekosnegocios.com/image/posts/December2024/xZOv1p7aKZpYIXbSDtTi.webp',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Color(0xAA000000), // overlay oscuro para que se lean los campos
            ),
          ),

          // Contenido del formulario
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: const Text(
                    'Debe llenar los siguientes campos',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(179, 255, 255, 255),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const _CampoTexto(
                  label: 'Nombre',
                  icon: Icons.person,
                ),
                const SizedBox(height: 12),

                const _CampoTexto(
                  label: 'Apellido',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 12),

                const _CampoTexto(
                  label: 'Correo electrónico',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),

                const _CampoTexto(
                  label: 'Contraseña',
                  icon: Icons.lock,
                  obscure: true,
                ),
                const SizedBox(height: 12),

                const _CampoTexto(
                  label: 'Teléfono',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),

                const _CampoTexto(
                  label: 'País',
                  icon: Icons.public,
                ),
                const SizedBox(height: 12),

                _FechaNacimientoField(color: primaryPurple),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color.fromARGB(218, 66, 10, 66),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Registro enviado')),
                      );
                    },
                    child: const Text(
                      'Registrarse',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ------------ Widgets reutilizables ------------

class _CampoTexto extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;

  const _CampoTexto({
    required this.label,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.purpleAccent),
        ),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
      ),
    );
  }
}

class _FechaNacimientoField extends StatefulWidget {
  final Color color;
  const _FechaNacimientoField({required this.color});

  @override
  State<_FechaNacimientoField> createState() => _FechaNacimientoFieldState();
}

class _FechaNacimientoFieldState extends State<_FechaNacimientoField> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: widget.color,
              onPrimary: Colors.white,
              surface: const Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _controller.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      readOnly: true,
      style: const TextStyle(color: Colors.white),
      onTap: _pickDate,
      decoration: InputDecoration(
        labelText: 'Fecha de nacimiento',
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.cake, color: Colors.white70),
        suffixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: widget.color),
        ),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
      ),
    );
  }
}
