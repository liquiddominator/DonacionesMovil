import 'package:flutter/material.dart';

class TipoDonacionSelector extends StatelessWidget {
  final String tipoSeleccionado;
  final Function(String) onChangedTipo;
  final double? montoSeleccionado;
  final Function(double) onMontoChanged;
  final TextEditingController montoController;
  final TextEditingController descripcionController;

  const TipoDonacionSelector({
    super.key,
    required this.tipoSeleccionado,
    required this.onChangedTipo,
    required this.montoSeleccionado,
    required this.onMontoChanged,
    required this.montoController,
    required this.descripcionController,
  });

  @override
  Widget build(BuildContext context) {
    final List<double> montos = [50, 100, 200, 500, 1000];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Donación',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildTipoOption(
                context: context,
                label: 'Monetaria',
                icon: Icons.attach_money,
                selected: tipoSeleccionado == 'Monetaria',
                onTap: () => onChangedTipo('Monetaria'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTipoOption(
                context: context,
                label: 'En Especie',
                icon: Icons.inventory_2_outlined,
                selected: tipoSeleccionado == 'Especie',
                onTap: () => onChangedTipo('Especie'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        if (tipoSeleccionado == 'Monetaria') ...[
          const Text(
            'Monto a donar (Bs.)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
  builder: (context, constraints) {
    final spacing = 12.0;
    final buttonsPerRow = 3;
    final totalSpacing = spacing * (buttonsPerRow - 1);
    final buttonWidth = (constraints.maxWidth - totalSpacing) / buttonsPerRow;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        ...montos.map((monto) => _buildMontoButton(
              label: '${monto.toStringAsFixed(0)} Bs.',
              selected: montoSeleccionado == monto,
              width: buttonWidth,
              onTap: () {
                onMontoChanged(monto);
                montoController.text = monto.toStringAsFixed(0);
              },
            )),
        _buildMontoButton(
          label: 'Otro',
          selected: !montos.contains(montoSeleccionado),
          width: buttonWidth,
          onTap: () {
            onMontoChanged(-1);
            montoController.text = '';
          },
        ),
      ],
    );
  },
),

          const SizedBox(height: 12),

          // Input con mismo estilo que las casillas
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFDE8DC),
                width: 2,
              ),
            ),
            child: TextFormField(
              controller: montoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: InputBorder.none,
                hintText: 'Monto personalizado',
              ),
              validator: (value) {
                final monto = double.tryParse(value ?? '');
                if (monto == null || monto <= 0) {
                  return 'Ingresa un monto válido';
                }
                return null;
              },
            ),
          ),
        ],

        if (tipoSeleccionado == 'Especie') ...[
          const Text(
            'Descripción de la donación',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),

          // Caja de texto igual que las casillas
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFDE8DC),
                width: 2,
              ),
            ),
            child: TextFormField(
              controller: descripcionController,
              maxLines: 3,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: InputBorder.none,
                hintText: 'Describe que vas a donar\n(medicamentos, equipos medicos, insumos, etc.)',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La descripción es obligatoria';
                }
                return null;
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTipoOption({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF1E6) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFFF58C5B) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? const Color(0xFFF58C5B) : Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: selected ? const Color(0xFFF58C5B) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMontoButton({
  required String label,
  required bool selected,
  required VoidCallback onTap,
  required double width,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: width,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFFFF1E6) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? const Color(0xFFF58C5B) : const Color(0xFFFDE8DC),
          width: 2,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: selected ? const Color(0xFFF58C5B) : Colors.black87,
        ),
      ),
    ),
  );
}

}