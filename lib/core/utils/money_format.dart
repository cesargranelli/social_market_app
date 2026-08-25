/// Formata valores monetários no padrão PT-BR simples (ex.: `R$ 9,90`),
/// sem depender de pacote de internacionalização. Função pura/testável.
String formatBrl(num value) {
  final String withCents = value.toStringAsFixed(2);
  return 'R\$ ${withCents.replaceAll('.', ',')}';
}
