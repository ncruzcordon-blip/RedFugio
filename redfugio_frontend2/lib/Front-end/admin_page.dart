import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redfugio_frontend2/features/authentication/models/user_model.dart';
import 'package:redfugio_frontend2/features/authentication/providers/auth_provider.dart';
import 'package:redfugio_frontend2/features/users/providers/user_provider.dart';

class Admin extends StatefulWidget {
  const Admin({Key? key}) : super(key: key);

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin>{

  bool _cargaIniciada = false;

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();

    final authProvider = context.watch<AuthProvider>();

    debugPrint('¿TOKEN EXISTE?: ${authProvider.token != null}');

    if (!_cargaIniciada && authProvider.token != null) {
      _cargaIniciada = true;

      debugPrint('INICIANDO CARGA DE USUARIOS');

      // context.read<UserProvider>().getUsers(
      //   authProvider.token!,
      // );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final token = context.read<AuthProvider>().token;
        if (token != null) context.read<UserProvider>().getUsers(token);
      });
    }

    /*if(!_cargaIniciada){
      _cargaIniciada = true;
    }
    
    final token = context.read<AuthProvider>().token;

    if(token != null){
      context.read<UserProvider>().getUsers(token);
    }*/
  }

  Future<void> _accionUsuario(UserModel usuario, String accion) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    final provider = context.read<UserProvider>();
//     String? nombre;
    Map<String, String>? cambios;

    if (accion == 'eliminar') {
      final confirmado = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Eliminar usuario'),
          content: Text('?Quieres eliminar a ${usuario.name}?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
          ],
        ),
      );
      if (confirmado != true || !mounted) return;
    } else if (accion == 'editar') {
//       var nuevoNombre = usuario.name;
//       nombre = await showDialog<String>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('Editar usuario'),
//           content: TextFormField(initialValue: nuevoNombre, onChanged: (valor) => nuevoNombre = valor, decoration: const InputDecoration(labelText: 'Nombre')),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
//             TextButton(onPressed: () => Navigator.pop(context, nuevoNombre.trim()), child: const Text('Guardar')),
//           ],
//         ),
//       );
//       if (nombre == null || nombre.isEmpty || !mounted) return;
      cambios = await _editarUsuario(usuario);
      if (cambios == null || !mounted) return;
    }

    final bool exito;
    switch (accion) {
      case 'activar':
        exito = await provider.activateUser(usuario.id, token);
        break;
      case 'desactivar':
        exito = await provider.deactivateUser(usuario.id, token);
        break;
      case 'eliminar':
        exito = await provider.deleteUser(usuario.id, token);
        break;
      case 'editar':
//         exito = await provider.updateUser(usuario.id, nombre!, token);
        exito = await provider.updateUser(usuario.id, cambios!['name']!, token, email: cambios['email'], role: cambios['role'], organizationName: cambios['organization_name']);
        break;
      default:
        return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(exito ? 'Operaci?n realizada correctamente.' : 'No se ha podido realizar la operaci?n.'),
      content: Text(exito ? 'Operación realizada correctamente.' : (accion == 'editar' ? provider.errorMessage : null) ?? 'No se ha podido realizar la operación.'),
    ));
  }

  Future<Map<String, String>?> _editarUsuario(UserModel usuario) {
    final formKey = GlobalKey<FormState>();
    var nombre = usuario.name;
    var email = usuario.email;
    var rol = usuario.role.code;
    var organizacion = usuario.organizationName ?? '';
    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, actualizar) => AlertDialog(
          title: const Text('Editar usuario'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: nombre,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    onChanged: (valor) => nombre = valor.trim(),
                    validator: (valor) => valor == null || valor.trim().isEmpty ? 'Requerido' : null,
                  ),
                  TextFormField(
                    initialValue: email,
                    decoration: const InputDecoration(labelText: 'Correo electrónico'),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (valor) => email = valor.trim(),
                    validator: (valor) => valor != null && RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(valor.trim()) ? null : 'Correo electrónico no válido',
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: rol,
                    decoration: const InputDecoration(labelText: 'Tipo de cuenta'),
                    items: const [
                      DropdownMenuItem(value: 'u', child: Text('Usuario')),
                      DropdownMenuItem(value: 'p', child: Text('Profesional/Entidad')),
                    ],
                    onChanged: (valor) { if (valor != null) actualizar(() => rol = valor); },
                  ),
                  TextFormField(
                    initialValue: organizacion,
                    enabled: rol == 'p',
                    decoration: const InputDecoration(labelText: 'Organización'),
                    onChanged: (valor) => organizacion = valor.trim(),
                    validator: (valor) => rol == 'p' && (valor == null || valor.trim().isEmpty) ? 'Indica el nombre de tu organización' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, {'name': nombre, 'email': email, 'role': rol, 'organization_name': rol == 'p' ? organizacion : ''});
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botonAccion(UserModel usuario, String accion, String etiqueta, IconData icono, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: Tooltip(
            message: etiqueta,
            child: InkWell(
              onTap: () => _accionUsuario(usuario, accion),
              child: Center(child: Icon(icono, color: Colors.white, size: 18)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _crearEtiqueta(String texto, Color color) {

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),

      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 200, 200),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(texto, style: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),),
    );
  }


  @override
  Widget build(BuildContext context){

    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 231, 231, 231),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.centerLeft,
            heightFactor: 1,
            child: ElevatedButton.icon(
              onPressed: () => context.read<AuthProvider>().logout(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(255, 151, 151, 1),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
            children: [
             
//CABECERA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                color: const Color.fromRGBO(255, 151, 151, 1),

                  child: Row(
                    children: [

                      IconButton(onPressed: (){
                        context.read<AuthProvider>().logout();
                      }, 
                        icon: Icon(
                        Icons.arrow_back,
                        size: 28,
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ), ), 
                      
                        const SizedBox(width: 8),

                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Gestión de usuarios', 
                            style: TextStyle(fontSize: 23, color: Colors.white, fontWeight: FontWeight.bold), 
                            ),
                          ],
                        ),
                    ],
                  ),
              ),
              
              SizedBox(height: 10),

//TEXTO INFORMATIVO
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),

                child: const Align(
                  alignment: Alignment.centerLeft,

                  child: Text('DESLIZA UNA FILA PARA VER LAS ACCIONES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),

              ),
        
//LISTA DE USUARIOS
              Expanded(
                child: Builder(
                  builder: (context) {

                    //CARGANDO
                    if(userProvider.isLoading){
                      return const Center(child: CircularProgressIndicator());
                    }

                    //ERROR
                    if(userProvider.errorMessage != null){
                      return Center(
                        child: Text(
                          userProvider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    //LISTA VACÍA
                    if(userProvider.users.isEmpty){
                      return const Center(
                        child: Text('No hay usuarios registrados'),
                      );
                    }

                    //LISTA DE USUARIOS
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 15),

                      itemCount: userProvider.users.length,

                      itemBuilder: (context, index){

                        final usuario = userProvider.users[index];

                        //Obtener iniciales
                        final partesNombre = usuario.name.trim().split(' ');

                        final iniciales = partesNombre
                          .where((parte) => parte.isNotEmpty)
                          .take(2)
                          .map((parte) => parte[0].toUpperCase())
                          .join();

                        //obtener tipo de cuenta
                        String tipo;

                        switch(usuario.role){
                          case UserRole.user: 
                            tipo = 'Usuario';
                            break;
                          
                          case UserRole.professional:
                            tipo = 'Profesional';
                            break;

                          case UserRole.admin: 
                            tipo = 'Administrador';
                            break;
                        }

                        return Slidable(
                          key: ValueKey(usuario.id),
                          endActionPane: usuario.role == UserRole.admin ? null : ActionPane(
                            motion: const ScrollMotion(),
                            extentRatio: 0.16,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    _botonAccion(usuario, 'activar', 'Activar', Icons.check, Colors.green),
                                    _botonAccion(usuario, 'desactivar', 'Desactivar', Icons.pause, Colors.orange),
                                    _botonAccion(usuario, 'editar', 'Editar', Icons.edit, Colors.blue),
                                    _botonAccion(usuario, 'eliminar', 'Eliminar', Icons.delete_outline, Colors.red),
                                  ],
                                ),
                              ),
                            ],
                          ),
//                           endActionPane: usuario.role == UserRole.admin ? null : ActionPane(
//                             motion: const ScrollMotion(),
//                             extentRatio: 0.8,
//                             children: [
//                               SlidableAction(
//                                 onPressed: (_) => _accionUsuario(usuario, usuario.active ? 'desactivar' : 'activar'),
//                                 icon: usuario.active ? Icons.block : Icons.check,
//                                 label: usuario.active ? 'Desactivar' : 'Activar',
//                                 backgroundColor: Colors.orange,
//                               ),
//                               SlidableAction(
//                                 onPressed: (_) => _accionUsuario(usuario, 'editar'),
//                                 icon: Icons.edit,
//                                 label: 'Editar',
//                                 backgroundColor: Colors.blue,
//                               ),
//                               SlidableAction(
//                                 onPressed: (_) => _accionUsuario(usuario, 'eliminar'),
//                                 icon: Icons.delete,
//                                 label: 'Eliminar',
//                                 backgroundColor: Colors.red,
//                               ),
//                             ],
//                           ),
                          child: Card(
                          color: Colors.white,
                          elevation: 1,

                          margin: const EdgeInsets.only(bottom: 10),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(14),
                          ),

                          child: Padding(
                            padding: const EdgeInsetsGeometry.all(12),
                            
                            child: Row(
                              children: [

                                //AVATAR
                                CircleAvatar(radius: 22,
                                  backgroundColor: const Color(0xFFE2F4F1),
                                  
                                  child: Text(
                                    iniciales,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                              const SizedBox(width: 12),
                              //INFORMACION DEL USUARIO
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [

                                  Text(
                                    usuario.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    )
                                  ),

                                  const SizedBox(height: 3),

                                  Text(
                                    usuario.email,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),

                                  const SizedBox(height: 7),

                                   Row(
                                  children: [

                                  //TIPO DE CUENTA
                                  _crearEtiqueta(
                                    tipo,
                                    Colors.green,
                                  ),

                                  const SizedBox(height: 6),

                                  //ESTADO
                                  _crearEtiqueta(
                                    usuario.active ? 'Activo' : 'Inactivo',
                                    usuario.active ? Colors.green : Colors.orange,
                                    
                                  ),

                                  ],
                                )
                                ],
                              )
                            ),
                           ],
                         ),
                          ),
                          ),
                        );
                      }
                    );
                  },
                ),
              ),
          ]
        )
      )
    );
  }
}