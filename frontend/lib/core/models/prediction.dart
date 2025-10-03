class Prediction {
  final String id;
  final String itemId;
  final String itemName;
  final DateTime predictionDate;
  final int predictedDemand;
  final double confidence;
  final PredictionLevel level;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  Prediction({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.predictionDate,
    required this.predictedDemand,
    required this.confidence,
    required this.level,
    required this.metadata,
    required this.createdAt,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      id: json['id'],
      itemId: json['item_id'],
      itemName: json['item_name'],
      predictionDate: DateTime.parse(json['prediction_date']),
      predictedDemand: json['predicted_demand'],
      confidence: json['confidence'].toDouble(),
      level: PredictionLevel.values.firstWhere(
        (e) => e.toString().split('.').last == json['level'],
        orElse: () => PredictionLevel.medium,
      ),
      metadata: json['metadata'] ?? {},
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'item_name': itemName,
      'prediction_date': predictionDate.toIso8601String(),
      'predicted_demand': predictedDemand,
      'confidence': confidence,
      'level': level.toString().split('.').last,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get levelDisplayName {
    switch (level) {
      case PredictionLevel.low:
        return 'Bajo';
      case PredictionLevel.medium:
        return 'Medio';
      case PredictionLevel.high:
        return 'Alto';
    }
  }

  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';

  bool get isHighConfidence => confidence >= 0.8;
  bool get isMediumConfidence => confidence >= 0.6 && confidence < 0.8;
  bool get isLowConfidence => confidence < 0.6;

  Prediction copyWith({
    String? id,
    String? itemId,
    String? itemName,
    DateTime? predictionDate,
    int? predictedDemand,
    double? confidence,
    PredictionLevel? level,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return Prediction(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      predictionDate: predictionDate ?? this.predictionDate,
      predictedDemand: predictedDemand ?? this.predictedDemand,
      confidence: confidence ?? this.confidence,
      level: level ?? this.level,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum PredictionLevel {
  low,
  medium,
  high,
}

class PredictionSummary {
  final DateTime date;
  final List<Prediction> predictions;
  final Map<String, dynamic> aggregateMetrics;

  PredictionSummary({
    required this.date,
    required this.predictions,
    required this.aggregateMetrics,
  });

  factory PredictionSummary.fromJson(Map<String, dynamic> json) {
    return PredictionSummary(
      date: DateTime.parse(json['date']),
      predictions: (json['predictions'] as List)
          .map((p) => Prediction.fromJson(p))
          .toList(),
      aggregateMetrics: json['aggregate_metrics'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'predictions': predictions.map((p) => p.toJson()).toList(),
      'aggregate_metrics': aggregateMetrics,
    };
  }

  int get totalPredictedDemand =>
      predictions.fold(0, (sum, p) => sum + p.predictedDemand);

  double get averageConfidence {
    if (predictions.isEmpty) return 0.0;
    return predictions.fold(0.0, (sum, p) => sum + p.confidence) /
        predictions.length;
  }

  List<Prediction> get highDemandPredictions =>
      predictions.where((p) => p.level == PredictionLevel.high).toList();

  List<Prediction> get lowConfidencePredictions =>
      predictions.where((p) => p.isLowConfidence).toList();
}
