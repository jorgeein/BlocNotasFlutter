import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('notas');
  runApp(bloc_Notas_App());
}

class bloc_Notas_App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notas App',
      home: PantallaListaNotas(),
    );
  }
}

class PantallaListaNotas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 243, 33, 33),
        title: Text('Bloc de notas'),
      ),
      body: ListaNotas(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaAgregarNota(),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 243, 33, 33),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class ListaNotas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ValueListenableBuilder(
        valueListenable: Hive.box('notas').listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return Center(child: Text('No hay notas'));
          }
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
            ),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final nota = box.getAt(index) as String;
              return InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PantallaDetalleNota(index),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: Colors.grey[200],
                        padding: EdgeInsets.all(5.0),
                        child: Text('Nota ${index + 1}'),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            nota,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PantallaDetalleNota extends StatelessWidget {
  final int index;

  PantallaDetalleNota(this.index);

  @override
  Widget build(BuildContext context) {
    final nota = Hive.box('notas').getAt(index) as String;
    return Scaffold(
      appBar: AppBar(title: Text('Detalle de la nota'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navegar a la pantalla de edición cuando se presiona el botón
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PantallaEditarNota(index: index, notaActual: nota),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              Hive.box('notas').deleteAt(index);
              Navigator.pop(context);
            },
          ),
        ],
      ), body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(nota),
      ),
    );
  }
}

class PantallaEditarNota extends StatelessWidget {
  final TextEditingController _textController;
  final int index;
  final String notaActual;

  PantallaEditarNota({required this.index, required this.notaActual})
      : _textController = TextEditingController(text: notaActual);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Nota'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
            ),
            ElevatedButton(
              onPressed: () {
                final nuevaNota = _textController.text;
                if (nuevaNota.isNotEmpty) {
                  Hive.box('notas').putAt(index, nuevaNota);
                }
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

class PantallaAgregarNota extends StatelessWidget {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agregar Nota')),
      body: Padding(
        padding: EdgeInsets.all(35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(labelText: 'Nota'),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                expands: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                onPressed: () {
                  final nota = _textController.text;
                  if (nota.isNotEmpty) {
                    Hive.box('notas').add(nota);
                  }
                  Navigator.pop(context);
                },
                child: Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
