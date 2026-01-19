import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
  id: root
  property alias text: buttonText.text
  property alias textColor: buttonText.color
  property bool enabled: true
  property bool isFocused: activeFocus || mouseArea.containsMouse
  property bool isActive: root.enabled && mArea.containsMouse


  /**
    * @var Qt::MouseButtons acceptedButtons
    * This property holds the mouse buttons that the mouse area reacts to.
    * See <a href="https://doc.qt.io/qt-5/qml-qtquick-mousearea.html#acceptedButtons-prop">Qt documentation</a>.
    */
  property alias acceptedButtons: mArea.acceptedButtons


  /**
    * @var mouseArea Mouse area element covering the button.
    */
  property alias mouseArea: mArea


  /** This property Enables accessibility of QML items.
    * See <a href="https://doc.qt.io/qt-5/qml-qtquick-accessible.html">Qt documentation</a>.
    */
  Accessible.role: Accessible.Button
  Accessible.name: qsTr("RButton")
  Accessible.onPressAction: root.clicked(null)

  implicitHeight: 48
  implicitWidth: 48

  // ----- Signal declarations
  signal pressed
  signal released
  signal clicked

  Rectangle {
    id: bgrRecrt
    anchors.fill: parent
    radius: 8
    border.color: "black"
    border.width: 2
    color: "darkgrey"

    Item {
      anchors.fill: parent
      Text {
        id: buttonText
        text: "W"
        anchors.centerIn: parent
        font {
          family: AppSingleton.gameFont.name
          pointSize: AppSingleton.middleFontSize
        }
      }
    }
    layer.enabled: true
    layer.effect: DropShadow {
      anchors.fill: bgrRecrt
      horizontalOffset: 3
      verticalOffset: 4
      radius: 5
      samples: 11
      color: "black"
      opacity: 0.75
    }
  }
  // ----- States and transitions.
  states: [
    State {
      name: "active"
      when: root.enabled && root.isFocused && !mArea.pressed
      PropertyChanges {
        target: bgrRecrt
        opacity: 0.8
      }
    },
    State {
      name: "pressed"
      when: root.enabled && mArea.pressed
      PropertyChanges {
        target: bgrRecrt
        scale: 0.8
      }
    },
    State {
      name: "released"
      when: mouseArea.released
    },
    State {
      name: "hover"
      when: root.enabled && root.isFocused && !mArea.pressed
      PropertyChanges {
        target: bgrRecrt
        opacity: 1.0
      }
    }
  ]

  transitions: Transition {
    NumberAnimation {
      properties: scale
      easing.type: Easing.InOutQuad
      duration: AppSingleton.delay_200
    }
    NumberAnimation {
      properties: opacity
      easing.type: Easing.InOutQuad
      duration: AppSingleton.delay_200
    }
  }
  MouseArea {
    id: mArea

    anchors.fill: parent
    cursorShape: isActive ? Qt.PointingHandCursor : Qt.ArrowCursor

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton

    onPressed: {
      root.focus = true
      root.pressed()
    }
    onClicked: {
      root.focus = true
      root.clicked()
    }
    onReleased: {
      root.focus = true
      root.released()
    }

    onHoveredChanged: {
      root.state == 'hover' ? root.state = "" : root.state = 'hover'
    }
  }
}
