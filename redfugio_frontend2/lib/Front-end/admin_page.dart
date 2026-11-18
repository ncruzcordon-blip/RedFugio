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
  bool _accionEnCurso = false;

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();

    final authProvider = context.watch<AuthProvider>();

    debugPrint('¿TOKEN EXISTE?: ${authProvider.token != null}');

    if (!_cargaIniciada && authProvider.token != null) {
      _cargaIniciada = true;

      debugPrint('INICIANDO CARGA DE USUARIOS');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final token = context.read<AuthProvider>().token;
        if (token != null) context.read<UserProvider>().getUsers(token);
      });
    }
  }

  Future<void> _accionUsuario(UserModel usuario, String accion) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    final provider = context.read<UserProvider>();
    if (_accionEnCurso || (accion == 'activar' && usuario.active) || (accion == 'desactivar' && !usuario.active)) {
      return;
    }
    if (accion == 'activar' && usuario.role == UserRole.professional) {
      final confirmado = await _confirmarEntidad(usuario);
      if (confirmado != true || !mounted) return;
    }

    Map<String, String>? cambios;

//CONFIRMACION ELIMINAR USUARIO
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
      cambios = await _editarUsuario(usuario);
      if (cambios == null || !mounted) return;
    }

    setState(() => _accionEnCurso = true);
    try {
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
        exito = await provider.updateUser(usuario.id, cambios!['name']!, token);
        break;
      default:
        return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(exito ? 'Operación realizada correctamente.' : (accion == 'editar' ? provider.actionErrorMessage : null) ?? 'No se ha podido realizar la operación.'),
    ));
    } finally {
      if (mounted) setState(() => _accionEnCurso = false);
    }
  }

//CONFIRMACION INSTITUCIÓN
  Future<bool?> _confirmarEntidad(UserModel usuario) {
    final institucion = usuario.organizationName?.trim() ?? '';
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Expanded(child: Text('Verificar entidad')),
            IconButton(
              tooltip: 'Cerrar',
              onPressed: () => Navigator.pop(context, false),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        content: Text('Institución: ${institucion.isEmpty ? "Sin organización indicada" : institucion}\n\nConsulta y comprueba que esta institución existe y que el usuario la representa antes de confirmar la activación.'),
        actions: [
          ElevatedButton(
            onPressed: institucion.isEmpty ? null : () => Navigator.pop(context, true),
            child: const Text('Confirmar activación'),
          ),
        ],
      ),
    );
  }

//EDITAR USUARIO
  Future<Map<String, String>?> _editarUsuario(UserModel usuario) {
    final formKey = GlobalKey<FormState>();
    var nombre = usuario.name;
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
                  //editar nombre
                  TextFormField(
                    initialValue: nombre,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    onChanged: (valor) => nombre = valor.trim(),
                    validator: (valor) => valor == null || valor.trim().isEmpty ? 'Requerido' : null,
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
                  Navigator.pop(context, {'name': nombre});
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

//BOTONES ACTIVAR Y DESACTIVAR CUENTA
  Widget _botonAccion(UserModel usuario, String accion, String etiqueta, IconData icono, Color color) {
    final habilitada = !_accionEnCurso &&
        (accion != 'activar' || !usuario.active) &&
        (accion != 'desactivar' || usuario.active);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        child: Material(
          color: habilitada ? color : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: Tooltip(
            message: etiqueta,
            child: InkWell(
              onTap: habilitada ? () => _accionUsuario(usuario, accion) : null,
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
    final usuariosVisibles = userProvider.users
        .where((usuario) => usuario.role != UserRole.admin)
        .toList();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 231, 231, 231),
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

                    if(userProvider.errorMessage != null && usuariosVisibles.isEmpty){
                      return Center(
                        child: Text(
                          userProvider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    //LISTA VACÍA
                    if(usuariosVisibles.isEmpty){
                      return const Center(
                        child: Text('No hay usuarios registrados'),
                      );
                    }

                    //LISTA DE USUARIOS
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: usuariosVisibles.length,
                      itemBuilder: (context, index){
                        final usuario = usuariosVisibles[index];

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
                          
                          case UserRole.passerby:
                            tipo = 'Voluntario';
                            break;

                          case UserRole.professional:
                            tipo = 'Profesional';
                            break;

                          case UserRole.admin: 
                            tipo = 'Administrador';
                            break;
                        }

                        //botones 
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

                                //Avatar
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

                              //Info del usuario
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

                                  //tipo de cuenta
                                  _crearEtiqueta(
                                    tipo,
                                    const Color.fromARGB(255, 0, 0, 0),
                                  ),

                                  const SizedBox(height: 6),

                                  //estado
                                  _crearEtiqueta(
                                    usuario.active ? 'Activo' : 'Inactivo',
                                    usuario.active ? const Color.fromARGB(255, 0, 0, 0) : const Color.fromARGB(255, 60, 0, 170),
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
