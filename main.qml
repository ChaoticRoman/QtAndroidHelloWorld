import QtQuick 2.12
import QtQuick.Window 2.12

Window {
    visible: true
    visibility: "FullScreen"
    title: "Navigation map"

    Rectangle {
        anchors.fill: parent
        color: "white"
        Text {
            id: myLabel
            text: "Click me!"
            font.pointSize: 45
            verticalAlignment: "AlignVCenter"
            horizontalAlignment: "AlignHCenter"
            anchors.fill: parent
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                myLabel.text = "Thank you!";
                greetingEmitter.greet();

                // Both forms to support both Google Maps and Waze
                // "geo:lat,lon" for Waze and "geo:0,0?q=lat,lon" for Google maps
                // See for more https://developers.google.com/maps/documentation/urls/android-intents
                // Qt.openUrlExternally("geo:49.1679,17.5103?q=49.1679,17.5103");

                // This seems to be even better and it propmpts for prefferred app
                Qt.openUrlExternally("google.navigation:q=49.1679,17.5103");
            }
        }
    }
}
