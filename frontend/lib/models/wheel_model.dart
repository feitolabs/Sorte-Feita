import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/theme/app_colors.dart';

class WheelOption {
  final String id;
  String label;
  Color color;
  double weight;
  bool active;

  WheelOption({
    String? id,
    required this.label,
    Color? color,
    this.weight = 1.0,
    this.active = true,
  })  : id = id ?? const Uuid().v4(),
        color = color ?? AppColors.azulRio;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'color': color.value,
        'weight': weight,
        'active': active,
      };

  factory WheelOption.fromJson(Map<String, dynamic> json) => WheelOption(
        id: json['id'] as String?,
        label: json['label'] as String? ?? '',
        color: Color(json['color'] as int? ?? AppColors.azulRio.value),
        weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
        active: json['active'] as bool? ?? true,
      );

  WheelOption copyWith({
    String? label,
    Color? color,
    double? weight,
    bool? active,
  }) {
    return WheelOption(
      id: id,
      label: label ?? this.label,
      color: color ?? this.color,
      weight: weight ?? this.weight,
      active: active ?? this.active,
    );
  }
}

class WheelModel {
  final String id;
  String name;
  List<WheelOption> options;
  bool differentWeights;
  bool removeOnWin;
  DateTime createdAt;

  WheelModel({
    String? id,
    required this.name,
    required this.options,
    this.differentWeights = false,
    this.removeOnWin = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'options': options.map((o) => o.toJson()).toList(),
        'differentWeights': differentWeights,
        'removeOnWin': removeOnWin,
        'createdAt': createdAt.toIso8601String(),
      };

  factory WheelModel.fromJson(Map<String, dynamic> json) => WheelModel(
        id: json['id'] as String?,
        name: json['name'] as String? ?? 'Nova roleta',
        options: (json['options'] as List<dynamic>?)
                ?.map((e) => WheelOption.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        differentWeights: json['differentWeights'] as bool? ?? false,
        removeOnWin: json['removeOnWin'] as bool? ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );

  static WheelModel defaultFoodWheel() {
    return WheelModel(
      name: 'O que comer hoje',
      options: [
        WheelOption(label: 'Pizza', color: AppColors.petroleo, weight: 1.0),
        WheelOption(label: 'Japonês', color: AppColors.azulRio, weight: 1.0),
        WheelOption(label: 'Hambúrguer', color: AppColors.azulRioClaro, weight: 2.0),
        WheelOption(label: 'Marmita', color: AppColors.petroleo, weight: 1.0),
        WheelOption(label: 'Salada', color: AppColors.azulRio, weight: 1.0),
        WheelOption(label: 'Pastel', color: AppColors.nevoa, weight: 1.0, active: false),
      ],
      differentWeights: true,
      removeOnWin: false,
    );
  }
}

