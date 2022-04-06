<p align="center">
  <a href="https://rows.com">
  <br />
  <img src="https://rows.com/media/logo.svg" alt="Rows" width="150"/>
  <br />

  </a>
</p>

<p align="center">
<sub><strong>Spreadsheet with superpowers ✨!</strong></sub>
<br />
<br />
</p>

<p align="center">
  <a title="Pub" href="https://pub.dev/packages/tiny_charts" ><img src="https://img.shields.io/pub/v/tiny_charts.svg?style=popout" /></a>
  <a title="Rows lint" href="https://pub.dev/packages/rows_lint" ><img src="https://img.shields.io/badge/Styled%20by-Rows-754F6C?style=popout" /></a>
</p>


---


# Tiny charts 🤏
Sparkline charts for fast data visualization on Flutter apps


## Installation

```
flutter pub add tiny_charts
```

## Usage

## 📈 Line charts

### From offsets

![1](https://user-images.githubusercontent.com/6718144/148391931-3fdc57b8-eb66-4b0e-8cf3-d7fa39c20596.png)

```dart
void build(BuildContext context) {
  return TinyLineChart(
    width: 100,
    height: 28,
    dataPoints: const [
      Offset(0, 2),
      Offset(1, 11),
      Offset(2, 17),
      Offset(2.5, 0),
      Offset(3, 10),
      Offset(4, 24),
    ],
  );
}
```

### From vectors

Using vector_math's Vector2 class.

![2](https://user-images.githubusercontent.com/6718144/148391933-237c1b27-4594-400c-befc-68692610cba6.png)

```dart
import 'package:vector_math/vector_math.dart';

void build(BuildContext context) {
  return TinyLineChart.fromDataVectors(
    width: 100,
    height: 28,
    dataPoints: [
      Vector2(0, 14),
      Vector2(1, 13.2),
      Vector2(2, 2),
      Vector2(3, 13),
      Vector2(4, 10),
      Vector2(5, 4),
    ],
  );
}
```

### With options

Passing custom options

![3](https://user-images.githubusercontent.com/6718144/148391934-e6af0c29-6bf7-418d-ac2d-0fa22913bd37.png)

```dart
void build(BuildContext context) {
  return TinyLineChart(
    width: 100,
    height: 28,
    dataPoints: const [
      Offset(0, 2),
      Offset(1, 11),
      Offset(2, 17),
      Offset(2.5, 0),
      Offset(3, 10),
      Offset(4, 24),
    ],
    options: const TinyLineChartOptions(
      color: Color(0xFFC93B8C),
      lineWidth: 3,
      yMinLimit: -2,
      yMaxLimit: 27,
    ),
  );
}
```

## Bar charts

### Single

![1](https://user-images.githubusercontent.com/6718144/148391966-c5b92660-a833-4e8f-8adc-d37c5e23b6db.png)

```dart
void build(BuildContext context) {
  return TinyBarChart.single(
    value: 68.12,
    max: 100,
    color: const Color(0xFF236536),
    width: 120,
    height: 28,
  );
}
```

### Stacked

![2](https://user-images.githubusercontent.com/6718144/148391970-342d4260-2ea9-4a15-a4f1-09fad61775da.png)

```dart
void build(BuildContext context) {
  return TinyBarChart.stacked(
    data: const <double>[24, 12, 4],
    width: 120,
    height: 28,
  );
}
```

### From data vectors

![3](https://user-images.githubusercontent.com/6718144/148391975-6a410b0c-6c7b-48f7-b69c-17e176a0d9d2.png)

```dart
void build(BuildContext context) {
  return TinyBarChart.stackedFromDataVectors(
    dataPoints: <Vector2>[
      Vector2(1, 20),
      Vector2(2, 12),
      Vector2(0, 12),
      Vector2(4, 24),
    ],
  );
}
```

### With options

![4](https://user-images.githubusercontent.com/6718144/148391976-797c8687-9f70-4ac0-9669-eea00cf6a76e.png)

```dart
void build(BuildContext context) {
  return TinyBarChart.stacked(
    data: const <double>[24, 12, 4],
    options: const TinyBarChartOptions(
      colors: [
        Color(0xFFFF0000),
        Color(0xBEEE0260),
        Color(0x97FF74AD),
      ],
    ),
    width: 120,
    height: 28,
  );
}
```

## 📊 Column charts

### From values

![1](https://user-images.githubusercontent.com/6718144/148391994-d849b453-90ba-433d-98f9-ebd2cf480271.png)

```dart
void build(BuildContext context) {
  return TinyColumnChart(
    data: const [20, 22, 14, 12, 19, 28, 1, 11],
    width: 120,
    height: 28,
  );
}
```

### From vectors

![2](https://user-images.githubusercontent.com/6718144/148391999-7e8fa2be-6479-4512-9a79-09da88a50156.png)

```dart
void build(BuildContext context) {
  return TinyColumnChart.fromDataVectors(
    dataPoints: [
      Vector2(0, 18),
      Vector2(6, 22),
      Vector2(2, 12),
      Vector2(3, 14),
      Vector2(5, 34),
      Vector2(4, 5),
      Vector2(1, 24),
    ],
    width: 120,
    height: 28,
  );
}
```

### With negative values

![3](https://user-images.githubusercontent.com/6718144/148392000-0d1249c0-f969-41f4-8389-049eb38bc171.png)

```dart
void build(BuildContext context) {
  return TinyColumnChart(
    data: const [20, -22, 14, -12, -19, 28, 1, 11],
    width: 120,
    height: 28,
  );
}
```

## With options

* With axis

![4](https://user-images.githubusercontent.com/6718144/148392002-172a1327-d476-4d6d-a16a-03f4ac96bd62.png)

```dart
void build(BuildContext context) {
  return TinyColumnChart(
    data: const [20, -22, 14, -12, -19, 28, 5, 11],
    width: 120,
    height: 28,
    options: const TinyColumnChartOptions(
      positiveColor: Color(0xFF27A083),
      negativeColor: Color(0xFFE92F3C),
      showAxis: true,
    ),
  );
}
```

* Custom colors

![5](https://user-images.githubusercontent.com/6718144/148392004-d5d35bf1-4c86-4602-8309-b62c1062906f.png)

```dart
void build(BuildContext context) {
  return TinyColumnChart(
    data: const [18, 22, 28, -12, 32, 12, 9, 14, -34, -25, 24],
    width: 120,
    height: 28,
    options: const TinyColumnChartOptions(
      positiveColor: Color(0xFF0023C6),
      negativeColor: Color(0xFFBA2500),
      showAxis: true,
      axisColor: Color(0xFF00FF00),
      lowestColor: Color(0xFFFF4A1A),
      highestColor: Color(0xFF3083FF),
      firstColor: Color(0xFFFFE500),
      lastColor: Color(0xFF8000FF),
    ),
  );
}
```
