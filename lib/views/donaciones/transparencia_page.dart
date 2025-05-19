import 'package:donaciones_movil/models/saldos_donacion.dart';
import 'package:donaciones_movil/utils/currency_format.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:donaciones_movil/controllers/saldos_donacion_controller.dart';
import 'package:provider/provider.dart';

class TransparencyPage extends StatelessWidget {
  const TransparencyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transparencia de Fondos'),
      ),
      body: _buildTransparencyContent(context, currencyFormatter),
    );
  }

  Widget _buildTransparencyContent(BuildContext context, NumberFormat currencyFormat) {
    final saldosController = context.watch<SaldosDonacionController>();
    
    if (saldosController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (saldosController.error != null) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Error: ${saldosController.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => saldosController.loadSaldos(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    
    final saldos = saldosController.saldos ?? [];
    
    // Calcular totales
    double totalDonado = 0;
    double totalUtilizado = 0;
    
    for (var saldo in saldos) {
      totalDonado += saldo.montoOriginal;
      totalUtilizado += saldo.montoUtilizado ?? 0;
    }
    
    final double porcentajeUtilizado = totalDonado > 0 
        ? (totalUtilizado / totalDonado) * 100 
        : 0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Gráfico circular
                  SizedBox(
                    height: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: porcentajeUtilizado / 100,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[200],
                          color: Theme.of(context).primaryColor,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${porcentajeUtilizado.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'utilizado',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Detalles numéricos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTransparencyStat(
                        context,
                        title: 'Total Donado',
                        value: currencyFormat.format(totalDonado),
                        icon: Icons.account_balance_wallet,
                        color: Colors.green,
                      ),
                      _buildTransparencyStat(
                        context,
                        title: 'Total Utilizado',
                        value: currencyFormat.format(totalUtilizado),
                        icon: Icons.payments,
                        color: Colors.blue,
                      ),
                      _buildTransparencyStat(
                        context,
                        title: 'Saldo Disponible',
                        value: currencyFormat.format(totalDonado - totalUtilizado),
                        icon: Icons.savings,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Lista detallada de saldos
                  if (saldos.isNotEmpty) ...[
                    const Text(
                      'Detalle de Donaciones',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...saldos.map((saldo) => _buildSaldoItem(context, saldo, currencyFormat)).toList(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransparencyStat(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSaldoItem(BuildContext context, SaldosDonacion saldo, NumberFormat currencyFormat) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      elevation: 1,
      child: ListTile(
        leading: const Icon(Icons.monetization_on, color: Colors.green),
        title: Text(currencyFormat.format(saldo.montoOriginal)),
        subtitle: Text('Utilizado: ${currencyFormat.format(saldo.montoUtilizado ?? 0)}'),
        trailing: Text('${((saldo.montoUtilizado ?? 0) / saldo.montoOriginal * 100).toStringAsFixed(1)}%'),
      ),
    );
  }
}