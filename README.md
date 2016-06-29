# BLE-Experiments

## Features List

- Выделить основной используемый API классов  `CBCentralManager` и `CBPeripheral` из 'CoreBluetooth framework' в протоколы

- Создать прокси объекты которые удовлетворяют выделенным протоколам
- Добавить доп функционал в эти прокси классы:
    + Они являются делегатами классов  `CBCentralManager` и `CBPeripheral` (удовлетворяют протоколам `CBCentralManagerDelegate` и `CBPeripheralDelegate` cоответственно).
    + К каждому прокси классу можно добавить произвольное число обработчиков, при вызове метода делегата `CBCentralManagerDelegate` или `CBPeripheralDelegate` соотвествующее сообщение посылается каждому из зарегистрированных обоработчиков. **Цель:** разделить код обработки сообщений получаемых через методы делегата (например отделить полезный код и логгирование)
- Заменить `CBCentralManagerDelegate` и `CBPeripheralDelegate` аналогичными протоколами обработчиков (с аналогичным набором методов)
- Заменять другие классы из `CoreBluetooth` (например `CBService` или `CBCharacteristic`) на соответствующие прокси-классы не нужно
- Добавлена реализация блочных обработчиков
- Для конкретных классов обработчиков предлагается базовый класс, которых позволяет задат поток (thread) в котором будут вызваться блоки обработчиков
- таким образом можно получать сообщения от CBCentralManager и CBPeripheral в одном потоке,а обрабатывать в другом

### Errors

- `BTError` - base class for any error produced or wrapped by framework

- `CustomStringConvertible` & `CustomDebugStringConvertible` protocols support for BTError class and subclasses

## TODO List




