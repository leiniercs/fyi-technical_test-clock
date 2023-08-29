import QtQuick
import QtQuick.Window

Window {
    id: mainWindow
    width: 800
    height: 600
    visible: true
    title: qsTr("FYI - Technical Test - Clock")

    // Holds the current timestamp that is shown in the clock
    property double currentDateTime: new Date().getTime()

    // The current hour
    property int currentHour: 0

    // The current minute
    property int currentMinute: 0

    // The current second
    property int currentSecond: 0

    // Wether or not to update the clock
    property bool updateTime: true

    // Function that handle the change of time and update the variables
    // to be shown in the clock
    function dateTimeChanged() {
        // Increase one second
        currentDateTime += 1000

        // If the clock can be updated then update the variables
        // to be shown in the clock
        if (updateTime) {
            const dateTime = new Date(currentDateTime)

            currentHour = dateTime.getHours()
            currentMinute = dateTime.getMinutes()
            currentSecond = dateTime.getSeconds()
        }
    }

    // Update to update the current time to what the user selected in the clock
    function updateCurrentTime(hour, minute) {
        const dateTime = new Date(currentDateTime)

        dateTime.setHours(hour)
        dateTime.setMinutes(minute)
        currentDateTime = dateTime.getTime()
    }

    // Outer sphere
    Rectangle {
        id: outerSphere
        antialiasing: true
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height)
        height: Math.min(parent.width, parent.height)
        border.color: 'black'
        border.width: 40
        radius: width * 0.5
        color: 'transparent'
        z: 3
    }

    // Minutes bars
    Repeater {
        id: repInnerMinutes
        model: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59]

        delegate: Item {
            property bool dragging: false

            width: 20
            height: outerSphere.height / 2 - 38
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.verticalCenter
            transformOrigin: Item.Bottom
            rotation: 360 / repInnerMinutes.model.length * index
            z: handleMinute.held ? 2 : 0

            Rectangle {
                id: rInnerMinutes
                antialiasing: true
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                color: parent.dragging ? "gray" : "black"
                width: modelData % 5 === 0 ? 8 : 3
                height: modelData % 5 === 0 ? 25 : 20
            }

            // When the user is changing the minute and the mouse is over some minute indicator, highlight it.
            // If it is pressed then update the current time reflecting the new minute
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onEntered: {
                    if (handleMinute.held) {
                        parent.dragging = true
                    }
                }
                onExited: {
                    if (handleMinute.held) {
                        parent.dragging = false
                    }
                }
                onClicked: {
                    if (handleMinute.held) {
                        parent.dragging = false
                        handleMinute.held = false
                        mainWindow.updateCurrentTime(mainWindow.currentHour,
                                                     modelData)
                        mainWindow.updateTime = true
                    }
                }
            }
        }
    }

    // Second indicators in the outer sphere
    Repeater {
        id: repOuterMinutes
        model: [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]

        delegate: Item {
            width: 20
            height: outerSphere.width / 2 - 10
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.verticalCenter
            transformOrigin: Item.Bottom
            rotation: 360 / repOuterMinutes.model.length * index
            z: 4

            Text {
                id: tOuterMinutes
                antialiasing: true
                text: modelData
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                rotation: -parent.rotation
                font.pointSize: 12
                font.bold: true
                color: 'white'
            }
        }
    }

    // Hour indicators inside the clock
    Repeater {
        id: repInnerHours
        model: [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]

        delegate: Item {
            property bool dragging: false

            width: tInnerHour.implicitWidth
            height: outerSphere.width / 2 - 70
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.verticalCenter
            transformOrigin: Item.Bottom
            rotation: 360 / repInnerHours.model.length * index
            z: handleHour.held ? 2 : 0

            Text {
                id: tInnerHour
                antialiasing: true
                text: modelData
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                rotation: -parent.rotation
                font.pointSize: 35
                font.bold: true
                color: parent.dragging ? "gray" : "black"
            }

            // When the user is changing the hour and the mouse is over some hour indicator, highlight it.
            // If it is pressed then update the current time reflecting the new hour
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onEntered: {
                    if (handleHour.held) {
                        parent.dragging = true
                    }
                }
                onExited: {
                    if (handleHour.held) {
                        parent.dragging = false
                    }
                }
                onClicked: {
                    if (handleHour.held) {
                        parent.dragging = false
                        handleHour.held = false
                        mainWindow.updateCurrentTime(modelData,
                                                     mainWindow.currentMinute)
                        mainWindow.updateTime = true
                    }
                }
            }
        }
    }

    // The handle for the seconds
    Rectangle {
        anchors.bottom: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        transformOrigin: Item.Bottom
        rotation: 360 / 60 * currentSecond
        antialiasing: true
        color: 'black'
        width: 7
        height: outerSphere.height / 2 - 70
        Behavior on rotation {
            SpringAnimation {
                spring: 2
                damping: 0.2
                modulus: 360
            }
        }
    }

    // The handle for the minutes
    Item {
        property bool held: false

        id: handleMinute
        anchors.bottom: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        transformOrigin: Item.Bottom
        rotation: 360 / 60 * currentMinute
        width: 14
        height: outerSphere.height / 2 - 80
        z: 1

        Behavior on rotation {
            SpringAnimation {
                spring: 2
                damping: 0.2
                modulus: 360
            }
        }

        Rectangle {
            antialiasing: true
            anchors.fill: parent
            color: parent.held ? "grey" : "black"
        }

        // Start the selection of the minute and stop the time updating
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            //propagateComposedEvents: true
            onClicked: {
                parent.held = !parent.held
                mainWindow.updateTime = !mainWindow.updateTime
            }
        }
    }

    // The handle for the hours
    Item {
        property bool held: false

        id: handleHour
        anchors.bottom: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        transformOrigin: Item.Bottom
        rotation: 360 / 12 * currentHour
        width: 20
        height: outerSphere.height / 2 - 145
        z: 1

        Behavior on rotation {
            SpringAnimation {
                spring: 2
                damping: 0.2
                modulus: 360
            }
        }

        Rectangle {
            anchors.fill: parent
            antialiasing: true
            color: parent.held ? "grey" : "black"
        }

        // Start the selection of the hour and stop the time updating
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                parent.held = !parent.held
                mainWindow.updateTime = !mainWindow.updateTime
            }
        }
    }

    // The circle in the middle of the clock
    Rectangle {
        antialiasing: true
        anchors.centerIn: parent
        width: 30
        height: 30
        border.color: 'black'
        radius: width * 0.5
        color: 'black'
        z: 3
    }

    // Timer to update the current time
    Timer {
        id: timerDateTime
        interval: 1000
        running: true
        repeat: true
        onTriggered: mainWindow.dateTimeChanged()
    }

    Component.onCompleted: mainWindow.dateTimeChanged()
}
