import 'package:flutter/material.dart';

void main() => runApp(const EcoBarrioApp());

class Reporte {
  Reporte({required this.id, required this.titulo, required this.zona,
    required this.descripcion, required this.categoria, required this.fecha,
    this.resuelto = false});
  final int id;
  final String titulo;
  final String zona;
  final String descripcion;
  final String categoria;
  final DateTime fecha;
  bool resuelto;
}

class Jornada {
  Jornada({required this.titulo, required this.lugar, required this.fecha,
    required this.descripcion, this.inscrito = false});
  final String titulo;
  final String lugar;
  final String fecha;
  final String descripcion;
  bool inscrito;
}

class EcoBarrioApp extends StatelessWidget {
  const EcoBarrioApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'EcoBarrio', debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF16785A)),
      scaffoldBackgroundColor: const Color(0xFFF6F8F6),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF6F8F6))),
    home: const InicioPage(),
  );
}

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});
  @override State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  int actual = 0;
  String filtro = 'Todos';
  final buscador = TextEditingController();
  final List<Reporte> reportes = [
    Reporte(id: 1, titulo: 'Residuos en parque vecinal', zona: 'Parque Central',
      descripcion: 'Se observa acumulacion de residuos cerca de los juegos.',
      categoria: 'Basura', fecha: DateTime(2026, 11, 1)),
    Reporte(id: 2, titulo: 'Contenedores desbordados', zona: 'Av. Principal',
      descripcion: 'Los contenedores necesitan recojo frecuente.',
      categoria: 'Basura', fecha: DateTime(2026, 11, 2)),
    Reporte(id: 3, titulo: 'Restos de poda', zona: 'Plaza del Barrio',
      descripcion: 'Se deben retirar restos vegetales de la vereda.',
      categoria: 'Areas verdes', fecha: DateTime(2026, 11, 2), resuelto: true),
  ];
  final List<Jornada> jornadas = [
    Jornada(titulo: 'Limpieza comunitaria', lugar: 'Parque Central',
      fecha: 'Sabado 14 de noviembre, 9:00 a. m.',
      descripcion: 'Recoleccion voluntaria y separacion de residuos.'),
    Jornada(titulo: 'Taller de reciclaje', lugar: 'Local comunal',
      fecha: 'Sabado 21 de noviembre, 10:00 a. m.',
      descripcion: 'Aprende a clasificar residuos en casa.'),
  ];
  @override void dispose() { buscador.dispose(); super.dispose(); }
  void aviso(String texto) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  void nuevoReporte(Reporte reporte) {
    setState(() { reportes.insert(0, reporte); actual = 1; filtro = 'Todos'; buscador.clear(); });
    aviso('Reporte agregado en esta demostracion. No se envio a una autoridad.');
  }
  @override
  Widget build(BuildContext context) {
    final pages = [_panel(), _reportes(), _jornadas(), _aprende()];
    return Scaffold(
      appBar: AppBar(title: Row(children: [const Icon(Icons.eco, color: Color(0xFF16785A)),
        const SizedBox(width: 8), Text(['EcoBarrio', 'Reportes', 'Jornadas', 'Aprende'][actual],
          style: const TextStyle(fontWeight: FontWeight.bold))])),
      body: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: pages[actual]))),
      floatingActionButton: actual <= 1 ? FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => CrearReportePage(onGuardar: nuevoReporte,
            siguienteId: reportes.fold<int>(0, (m, r) => r.id > m ? r.id : m) + 1))),
        label: const Text('Nuevo reporte'), icon: const Icon(Icons.add)) : null,
      bottomNavigationBar: NavigationBar(selectedIndex: actual,
        onDestinationSelected: (index) => setState(() => actual = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.report_outlined), selectedIcon: Icon(Icons.report), label: 'Reportes'),
          NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups), label: 'Jornadas'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Aprende'),
        ]),
    );
  }
  Widget _panel() {
    final pendientes = reportes.where((r) => !r.resuelto).length;
    final resueltos = reportes.where((r) => r.resuelto).length;
    return ListView(padding: const EdgeInsets.all(18), children: [
      Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(
        color: const Color(0xFF16785A), borderRadius: BorderRadius.circular(22)),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.public, size: 38, color: Colors.white), SizedBox(height: 12),
          Text('Tu barrio, mas limpio entre todos', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
          SizedBox(height: 8), Text('Registra problemas ambientales, participa en jornadas y aprende a cuidar tu comunidad.',
            style: TextStyle(color: Colors.white, fontSize: 15))])),
      const SizedBox(height: 20),
      const Text('Resumen de la demostracion', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Row(children: [Expanded(child: _stat('Reportes', '${reportes.length}', Icons.article_outlined)),
        const SizedBox(width: 8), Expanded(child: _stat('Pendientes', '$pendientes', Icons.schedule)),
        const SizedBox(width: 8), Expanded(child: _stat('Resueltos', '$resueltos', Icons.check_circle_outline))]),
      const SizedBox(height: 18),
      Card(child: ListTile(leading: const Icon(Icons.add_location_alt_outlined),
        title: const Text('¿Encontraste un problema?'), subtitle: const Text('Crea un reporte en pocos pasos.'),
        trailing: const Icon(Icons.chevron_right), onTap: () => setState(() => actual = 1))),
      Card(child: ListTile(leading: const Icon(Icons.volunteer_activism_outlined),
        title: const Text('Participa en una jornada'), subtitle: const Text('Conoce las actividades comunitarias.'),
        trailing: const Icon(Icons.chevron_right), onTap: () => setState(() => actual = 2))),
      const SizedBox(height: 12),
      const Text('Prototipo academico: datos demostrativos; no existe conexion municipal ni envio externo.',
        style: TextStyle(color: Colors.black54, fontSize: 12)),
    ]);
  }
  Widget _stat(String titulo, String valor, IconData icono) => Card(
    child: Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      child: Column(children: [Icon(icono, color: const Color(0xFF16785A)),
        const SizedBox(height: 6), Text(valor, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(titulo, style: const TextStyle(fontSize: 11))])));

  Widget _reportes() {
    final visibles = reportes.where((r) {
      final texto = '${r.titulo} ${r.zona} ${r.descripcion}'.toLowerCase();
      final coincide = texto.contains(buscador.text.toLowerCase());
      final estado = filtro == 'Todos' || (filtro == 'Pendientes' && !r.resuelto)
        || (filtro == 'Resueltos' && r.resuelto);
      return coincide && estado;
    }).toList();
    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), child: TextField(
        controller: buscador, onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(prefixIcon: Icon(Icons.search),
          hintText: 'Buscar por lugar o problema', border: OutlineInputBorder()))),
      SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: ['Todos', 'Pendientes', 'Resueltos'].map((e) => Padding(
          padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(e),
            selected: filtro == e, onSelected: (_) => setState(() => filtro = e)))).toList())),
      Expanded(child: visibles.isEmpty
        ? const Center(child: Text('No hay reportes con estos filtros.'))
        : ListView.builder(padding: const EdgeInsets.fromLTRB(12, 8, 12, 90),
          itemCount: visibles.length, itemBuilder: (_, i) {
            final r = visibles[i];
            return Card(child: ListTile(
              leading: CircleAvatar(child: Icon(r.categoria == 'Basura' ? Icons.delete_outline : Icons.park_outlined)),
              title: Text(r.titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${r.zona} · ${r.categoria}\n${r.resuelto ? 'Resuelto' : 'Pendiente'}'),
              isThreeLine: true, trailing: const Icon(Icons.chevron_right),
              onTap: () => _detalle(r)));
          })),
    ]);
  }
  void _detalle(Reporte r) {
    showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      title: Text(r.titulo), content: Column(mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Zona: ${r.zona}'), Text('Categoria: ${r.categoria}'),
          Text('Fecha: ${r.fecha.day}/${r.fecha.month}/${r.fecha.year}'),
          const SizedBox(height: 12), Text(r.descripcion), const SizedBox(height: 12),
          Text('Estado: ${r.resuelto ? 'Resuelto' : 'Pendiente'}'),
        ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        if (!r.resuelto) FilledButton(onPressed: () {
          setState(() => r.resuelto = true);
          Navigator.pop(ctx); aviso('Marcado como resuelto SOLO en esta demostracion.');
        }, child: const Text('Marcar resuelto'))],
    ));
  }
  Widget _jornadas() => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Actividades comunitarias', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
    const SizedBox(height: 6), const Text('Eventos de ejemplo; fechas y lugares no son convocatorias reales.'),
    const SizedBox(height: 12), ...jornadas.map((j) => Card(child: Padding(
      padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.calendar_month, color: Color(0xFF16785A)), const SizedBox(height: 8),
        Text(j.titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6), Text(j.lugar), Text(j.fecha),
        const SizedBox(height: 6), Text(j.descripcion), const SizedBox(height: 12),
        FilledButton.tonalIcon(icon: Icon(j.inscrito ? Icons.check : Icons.person_add_alt),
          onPressed: () { setState(() => j.inscrito = !j.inscrito);
            aviso(j.inscrito ? 'Inscripcion de prueba registrada.' : 'Inscripcion de prueba cancelada.'); },
          label: Text(j.inscrito ? 'Inscrito (demo)' : 'Participar (demo)')),
      ]))))
  ]);
  Widget _aprende() => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Consejos para cuidar tu barrio', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
    const SizedBox(height: 12),
    ...const [
      ('Separa los residuos', 'Usa recipientes distintos para materiales aprovechables y residuos no aprovechables.', Icons.recycling),
      ('Reduce los desechables', 'Lleva una botella reutilizable y una bolsa de tela cuando sea posible.', Icons.shopping_bag_outlined),
      ('Cuida las areas verdes', 'No arrojes basura en parques y respeta las plantas de espacios comunes.', Icons.park_outlined),
      ('Participa en comunidad', 'Coordina con tus vecinos antes de organizar una jornada de limpieza.', Icons.handshake_outlined),
    ].map((c) => Card(child: ExpansionTile(leading: Icon(c.$3, color: const Color(0xFF16785A)),
      title: Text(c.$1), children: [Padding(padding: const EdgeInsets.all(16), child: Text(c.$2))]))),
    const SizedBox(height: 20), const Text('Reto ambiental', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
    const Text('¿Cual accion ayuda mas a reducir la basura en calles?'),
    const SizedBox(height: 8), FilledButton.tonal(onPressed: () => aviso('¡Correcto! Reducir y separar residuos ayuda a la comunidad.'),
      child: const Text('Separar residuos y usar menos desechables')),
    OutlinedButton(onPressed: () => aviso('Intenta de nuevo: botar basura en la calle aumenta el problema.'),
      child: const Text('Dejar residuos fuera del contenedor')),
  ]);
}

class CrearReportePage extends StatefulWidget {
  const CrearReportePage({super.key, required this.onGuardar, required this.siguienteId});
  final ValueChanged<Reporte> onGuardar;
  final int siguienteId;
  @override State<CrearReportePage> createState() => _CrearReportePageState();
}

class _CrearReportePageState extends State<CrearReportePage> {
  final keyForm = GlobalKey<FormState>();
  final titulo = TextEditingController();
  final zona = TextEditingController();
  final descripcion = TextEditingController();
  String categoria = 'Basura';
  @override void dispose() { titulo.dispose(); zona.dispose(); descripcion.dispose(); super.dispose(); }
  String? obligatorio(String? value) => value == null || value.trim().length < 4
    ? 'Escribe al menos 4 caracteres.' : null;
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Nuevo reporte')),
    body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 650),
      child: Form(key: keyForm, child: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('Describe el problema encontrado', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text('Los datos solo se mantienen mientras la aplicacion permanezca abierta.'),
        const SizedBox(height: 20),
        TextFormField(controller: titulo, validator: obligatorio,
          decoration: const InputDecoration(labelText: 'Titulo del problema', border: OutlineInputBorder())),
        const SizedBox(height: 16),
        TextFormField(controller: zona, validator: obligatorio,
          decoration: const InputDecoration(labelText: 'Zona o referencia', border: OutlineInputBorder())),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(initialValue: categoria,
          decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()),
          items: ['Basura', 'Areas verdes', 'Contaminacion', 'Otro']
            .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (value) => setState(() => categoria = value ?? 'Basura')),
        const SizedBox(height: 16),
        TextFormField(controller: descripcion, validator: obligatorio, maxLines: 4,
          decoration: const InputDecoration(labelText: 'Descripcion', border: OutlineInputBorder())),
        const SizedBox(height: 24),
        FilledButton.icon(icon: const Icon(Icons.save), label: const Text('Guardar reporte (demo)'),
          onPressed: () { if (keyForm.currentState!.validate()) {
            widget.onGuardar(Reporte(id: widget.siguienteId, titulo: titulo.text.trim(),
              zona: zona.text.trim(), descripcion: descripcion.text.trim(),
              categoria: categoria, fecha: DateTime.now()));
            Navigator.pop(context);
          }}),
      ])))),
  );
}
