import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jarlenmodas/core/consts.dart';
import 'package:jarlenmodas/widgets/exit_button_widget.dart';

class MenuItem {
  final String title;
  final List<MenuItem>? children;
  final Function(BuildContext context)? onTap;
  final IconData? icon;
  final bool isSelected;

  MenuItem({
    required this.title,
    this.children,
    this.onTap,
    this.icon,
    this.isSelected = false,
  });
}

class MenuItensWidget extends StatefulWidget {
  const MenuItensWidget({super.key});

  @override
  State<MenuItensWidget> createState() => _MenuItensWidgetState();
}

class _MenuItensWidgetState extends State<MenuItensWidget> {
  int? selectedIndex;
  int? expandedIndex;

  final List<MenuItem> menuItems = [
    MenuItem(title: "Administração", icon: Icons.admin_panel_settings),
    MenuItem(
      title: "Clientes",
      icon: Icons.person,
      children: [
        MenuItem(
          title: "Cadastro de Cliente",
          icon: Icons.add_circle,
          onTap: (context) {
            context.goNamed('create-client');
          },
        ),
        MenuItem(
          title: "Débitos Clientes",
          icon: Icons.money_off,
          onTap: (context) {
            context.goNamed('debit-client');
          },
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E3A8A), // Azul escuro
            Color(0xFF1E40AF), // Azul médio
            Color(0xFF2563EB), // Azul claro
          ],
        ),
      ),
      child: Column(
        children: [
          // Header com logo
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Informações do usuário
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white,
                      child: Text(
                        'A',
                        style: TextStyle(
                          color: Color(0xFF1E3A8A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Jarlen Modas',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ExitButton(
                      onExitConfirmed: () {
                        context.goNamed('login');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          // Menu items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                return _buildMenuItem(context, menuItems[index], index);
              },
            ),
          ),
          // Footer com logo
          Container(
            padding: const EdgeInsets.all(20),
            child: Image.asset(
              AppConsts.pathLogoEnterpriseNav,
              height: 80,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuItem item, int index) {
    final bool isSelected = selectedIndex == index;
    final bool isExpanded = expandedIndex == index;
    final bool hasChildren = item.children != null && item.children!.isNotEmpty;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withValues(alpha: (0.1 * 255))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            dense: true,
            leading: Icon(item.icon, color: Colors.white, size: 20),
            title: Text(
              item.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: hasChildren
                ? Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    color: Colors.white70,
                    size: 20,
                  )
                : null,
            onTap: () {
              setState(() {
                if (hasChildren) {
                  if (expandedIndex == index) {
                    expandedIndex = null;
                  } else {
                    expandedIndex = index;
                  }
                } else {
                  selectedIndex = index;
                  if (item.onTap != null) {
                    item.onTap!(context);
                  }
                }
              });
            },
          ),
        ),
        // Submenu items
        if (hasChildren && isExpanded)
          ...item.children!.map(
            (child) => Container(
              margin: const EdgeInsets.only(left: 30, right: 10),
              child: ListTile(
                dense: true,
                leading: Icon(
                  child.icon ?? Icons.circle,
                  color: Colors.white70,
                  size: 16,
                ),
                title: Text(
                  child.title,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                onTap: () {
                  if (child.onTap != null) {
                    child.onTap!(context);
                  }
                },
              ),
            ),
          ),
      ],
    );
  }
}
