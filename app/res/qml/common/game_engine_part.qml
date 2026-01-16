import QtQuick 2.15

Item {
  id: root
  focus: true
  // Свойство для отслеживания текущей нажатой клавиши
  property int currentPressedKey: -1
  property string currentPressedKeyName: getKeyName(currentPressedKey)
  property alias model: keysModel
  // Explicitly handling keys
  Keys.onPressed: {
    if (isKeyInModel(event.key)) {
      // Если нажата новая клавиша, а старая еще не отпущена
      if (currentPressedKey !== -1 && currentPressedKey !== event.key) {
        // Игнорируем другие клавиши, пока первая не отпущена
        console.log(`Игнорируем ${event.key}, пока нажата ${currentPressedKey}`)
        event.accepted = true
        return
      }
      // Если эта клавиша еще не была нажата
      if (!isKeyPressed(event.key)) {
        updateKeyPressed(event.key, true)
        currentPressedKey = event.key
        console.log(`${event.key} key pressed`)
        event.accepted = true
      }
    }
  }

  Keys.onReleased: {
    if (isKeyInModel(event.key)) {

      // Если отпущена текущая нажатая клавиша, сбрасываем
      if (currentPressedKey === event.key) {
        currentPressedKey = -1
        updateKeyPressed(event.key, false)
        console.log(`${event.key} key Released`)
      } else {
        console.log(
              `Игнорируем ${event.key} Released, пока нажата ${currentPressedKey}`)
      }
    }
  }

  ListModel {
    id: keysModel
    ListElement {
      keyCode: Qt.Key_0
      keyName: "0"
      pressed: false
    }
    ListElement {
      keyCode: Qt.Key_1
      keyName: "1"
      pressed: false
    }
    ListElement {
      keyCode: Qt.Key_2
      keyName: "2"
      pressed: false
    }
    ListElement {
      keyCode: Qt.Key_3
      keyName: "3"
      pressed: false
    }
    ListElement {
      keyCode: Qt.Key_4
      keyName: "4"
      pressed: false
    }
    ListElement {
      keyCode: Qt.Key_5
      keyName: "5"
      pressed: false
    }
    ListElement {
      keyCode: Qt.Key_6
      keyName: "6"
      pressed: false
    }
    ListElement {
      keyCode: Qt.Key_7
      keyName: "7"
      pressed: false
    }
  }
  //------------- JS functions -------------------------
  function isKeyInModel(keyCode) {
    for (var i = 0; i < keysModel.count; i++) {
      if (keysModel.get(i).keyCode === keyCode) {
        return true
      }
    }
    return false
  }

  function isAnyKeyInModelPressed() {
    for (var i = 0; i < keysModel.count; i++) {
      if (keysModel.get(i).pressed === true) {
        return true
      }
    }
    return false
  }

  function updateKeyPressed(keyCode, isPressed) {
    for (var i = 0; i < keysModel.count; i++) {
      if (keysModel.get(i).keyCode === keyCode) {
        keysModel.setProperty(i, "pressed", isPressed)
        break
      }
    }
  }

  function isKeyPressed(keyCode) {
    for (var i = 0; i < keysModel.count; i++) {
      if (keysModel.get(i).keyCode === keyCode) {
        return keysModel.get(i).pressed
      }
    }
  }
  function getKeyName(keyCode) {
    for (var i = 0; i < keysModel.count; i++) {
      if (keysModel.get(i).keyCode === keyCode) {
        return keysModel.get(i).keyName
      }
    }
    return "Empty"
  }
}
