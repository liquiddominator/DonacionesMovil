import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:donaciones_movil/models/usuario.dart';

class PersonalInfoCard extends StatelessWidget {
  final Usuario user;
  final bool editMode;
  final bool isLoading;
  final VoidCallback onSave;
  final TextEditingController nombreController;
  final TextEditingController apellidoController;
  final TextEditingController emailController;
  final TextEditingController telefonoController;
  final GlobalKey<FormState> formKey;

  const PersonalInfoCard({
    super.key,
    required this.user,
    required this.editMode,
    required this.isLoading,
    required this.onSave,
    required this.nombreController,
    required this.apellidoController,
    required this.emailController,
    required this.telefonoController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFE0CB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: const Row(
              children: [
                Icon(Icons.person, color: Colors.black87),
                SizedBox(width: 8),
                Text(
                  'Información Personal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: editMode
                  ? [
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFF58C5B),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: nombreController,
                                decoration: const InputDecoration(
                                  labelText: 'Nombre',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: apellidoController,
                                decoration: const InputDecoration(
                                  labelText: 'Apellido',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFF58C5B),
                          child: Icon(Icons.email, color: Colors.white),
                        ),
                        title: TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            border: InputBorder.none,
                          ),
                          validator: (value) => !value!.contains('@') ? 'Correo inválido' : null,
                        ),
                      ),
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFF58C5B),
                          child: Icon(Icons.phone_android, color: Colors.white),
                        ),
                        title: TextFormField(
                          controller: telefonoController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: isLoading ? null : onSave,
                            icon: const Icon(Icons.check_circle_outline, size: 20, color: Color(0xFFF58C5B)),
                            label: const Text(
                              'Guardar',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFF58C5B),
                              ),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFF58C5B),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]
                  : [
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFF58C5B),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(user.nombre, style: const TextStyle(fontSize: 16)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(user.apellido, style: const TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFF58C5B),
                          child: Icon(Icons.email, color: Colors.white),
                        ),
                        title: Text(user.email),
                      ),
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFF58C5B),
                          child: Icon(Icons.phone_android, color: Colors.white),
                        ),
                        title: Text(user.telefono ?? 'No registrado'),
                      ),
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFF58C5B),
                          child: Icon(Icons.calendar_today, color: Colors.white, size: 18),
                        ),
                        title: Text(
                          'Miembro desde ${DateFormat.yMMM('es_BO').format(user.fechaRegistro!)}',
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