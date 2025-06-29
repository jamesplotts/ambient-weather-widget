import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

Item {
    id: root

    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation

    property var weatherData: ({})
    property bool dataLoaded: false
    property string lastUpdateTime: ""
    property string errorMessage: ""

    property string apiKey: ""
    property string applicationKey: ""
    property string macAddress: ""
    property bool useFahrenheit: true
    property bool useImperial: true
    property int updateInterval: 10

    Timer {
        id: updateTimer
        interval: updateInterval * 60000
        running: apiKey !== "" && applicationKey !== "" && macAddress !== ""
        repeat: true
        triggeredOnStart: true
        onTriggered: fetchWeatherData()
    }

    function fetchWeatherData() {
        if (!apiKey || !applicationKey || !macAddress) {
            errorMessage = "Missing API credentials"
            return
        }

        var xhr = new XMLHttpRequest()
        var url = "https://rt.ambientweather.net/v1/devices/" + macAddress + "?apiKey=" + apiKey + "&applicationKey=" + applicationKey + "&limit=1"

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        if (response && response.length > 0) {
                            weatherData = response[0]
                            dataLoaded = true
                            errorMessage = ""
                            lastUpdateTime = new Date().toLocaleTimeString()
                        } else {
                            errorMessage = "No data received"
                        }
                    } catch (e) {
                        errorMessage = "Parse error: " + e.message
                    }
                } else {
                    errorMessage = "API Error: " + xhr.status
                }
            }
        }

        xhr.open("GET", url)
        xhr.send()
    }

    function formatTemperature(temp) {
        if (!temp && temp !== 0) return "--"
        if (useFahrenheit) {
            return Math.round(temp) + "°F"
        } else {
            return Math.round((temp - 32) * 5/9) + "°C"
        }
    }

    function formatWind(speed) {
        if (!speed && speed !== 0) return "--"
        if (useImperial) {
            return Math.round(speed) + " mph"
        } else {
            return Math.round(speed * 1.60934) + " km/h"
        }
    }

    function formatWindDir(direction) {
        if (349 < direction || direction < 11.5) return "N"
        if (11.5 < direction && direction < 34.1) return "NNE"
        if (34 < direction && direction < 56.6) return "NE"
        if (56.5 < direction && direction < 79.1) return "ENE"
        if (79 < direction && direction < 101.5) return "E"
        if (101.5 < direction && direction < 124.1) return "ESE"
        if (124 < direction && direction < 146.6) return "SE"
        if (146.5 < direction && direction < 169.1) return "SSE"
        if (169 < direction && direction < 191.6) return "S"
        if (191.5 < direction && direction < 214.1) return "SSW"
        if (214 < direction && direction < 236.6) return "SW"
        if (236.5 < direction && direction < 259.1) return "WSW"
        if (259 < direction && direction < 281.6) return "W"
        if (281.5 < direction && direction < 304.1) return "WNW"
        if (304 < direction && direction < 326.6) return "NW"
        if (326.5 < direction && direction < 349.1) return "NNW"
            return ""
    }

    function formatPressure(pressure) {
        if (!pressure && pressure !== 0) return "--"
        if (useImperial) {
            return pressure.toFixed(2) + " inHg"
        } else {
            return (pressure * 33.8639).toFixed(0) + " hPa"
        }
    }

    function toggle() {
        plasmoid.expanded = !plasmoid.expanded
    }

    function loadConfigFromFile() {
        var xhr = new XMLHttpRequest()
        var configPath = "file:///home/jamesp/.local/share/plasma/plasmoids/org.kde.plasma.ambientweather/apiconfig.txt"

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 0) {
                    try {
                        var lines = xhr.responseText.split('\n')
                        for (var i = 0; i < lines.length; i++) {
                            var line = lines[i].trim()
                            if (line && line.indexOf('=') > 0) {
                                var parts = line.split('=')
                                var key = parts[0].trim()
                                var value = parts[1].trim()

                                switch(key) {
                                    case 'apiKey':
                                        apiKey = value
                                        break
                                    case 'applicationKey':
                                        applicationKey = value
                                        break
                                    case 'macAddress':
                                        macAddress = value
                                        break
                                }
                            }
                        }
                        console.log("Config loaded - API Key length:", apiKey.length, "App Key length:", applicationKey.length)
                    } catch (e) {
                        console.log("Error parsing config file:", e.message)
                    }
                } else {
                    console.log("Could not load config file, status:", xhr.status)
                }
            }
        }

        xhr.open("GET", configPath)
        xhr.send()
    }

    Plasmoid.compactRepresentation: Rectangle {
        id: compactRoot
        width: 60
        height: 40
        color: "transparent"
        border.color: mouseArea.containsMouse ? "#3daee9" : "transparent"
        border.width: 1
        radius: 3

        Text {
            id: tempText
            anchors.centerIn: parent
            text: {
                if (errorMessage) return "ERR"
                if (!dataLoaded) return "..."
                return weatherData.tempf ? Math.round(useFahrenheit ? weatherData.tempf : (weatherData.tempf - 32) * 5/9) + "°" : "--"
            }
            font.pixelSize: 32
            font.bold: true
            color: errorMessage ? "#da4453" : "#eff0f1"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: toggle()
        }

        PlasmaCore.ToolTipArea {
            anchors.fill: parent
            mainText: "Ambient Weather Station"
            subText: {
                if (errorMessage) return errorMessage
                if (!dataLoaded) return "Loading..."
                var tooltip = ""
                if (weatherData.tempf) tooltip += "Temperature: " + formatTemperature(weatherData.tempf) + "\n"
                if (weatherData.feelsLike) tooltip += "Feels like " + formatTemperature(weatherData.feelsLike || weatherData.tempf) + "\n"
                if (weatherData.humidity) tooltip += "Humidity: " + weatherData.humidity + "%\n"
                if (weatherData.windspeedmph) tooltip += "Wind: " + formatWind(weatherData.windspeedmph) + " "
                if (weatherData.winddir_avg10m) tooltip += formatWindDir(weatherData.winddir_avg10m)
                tooltip += "\n"

                if (lastUpdateTime) tooltip += "Updated: " + lastUpdateTime
                return tooltip || "No data"
            }
        }
    }

    Plasmoid.fullRepresentation: Rectangle {
        id: fullRoot
        width: 320
        height: 180
        color: "#31363b"
        border.color: "#7f8c8d"
        border.width: 1
        radius: 6

        Text {
            id: errorLabel
            anchors.centerIn: parent
            text: errorMessage
            color: "#da4453"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            visible: errorMessage !== ""
            wrapMode: Text.WordWrap
            width: parent.width - 20
        }

        Text {
            anchors.centerIn: parent
            text: "Loading weather data..."
            color: "#bdc3c7"
            visible: !dataLoaded && errorMessage === ""
        }

        Column {
            anchors.centerIn: parent
            spacing: 15
            visible: !apiKey || !applicationKey || !macAddress

            Text {
                text: "Configuration Required"
                font.bold: true
                color: "#f67400"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "Edit apiconfig.txt file with your credentials"
                color: "#bdc3c7"
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Row {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 15
            visible: dataLoaded && errorMessage === ""

            Rectangle {
                width: 60
                height: 60
                color: "#3daee9"
                radius: 6

                Text {
                    anchors.centerIn: parent
                    text: "☀"
                    font.pixelSize: 30
                    color: "#31363b"
                }
            }

            Column {
                spacing: 8

                Text {
                    text: formatTemperature(weatherData.tempf)
                    font.pixelSize: 28
                    font.bold: true
                    color: "#eff0f1"
                }

                Text {
                    text: "Humidity: " + (weatherData.humidity || "--") + "%"
                    color: "#bdc3c7"
                    font.pixelSize: 16
                }

                Text {
                    text: "Feels like " + formatTemperature(weatherData.feelsLike || weatherData.tempf)
                    color: "#bdc3c7"
                    font.pixelSize: 16
                }

                Text {
                    text: "Wind: " + formatWind(weatherData.windspeedmph) + " " + formatWindDir(weatherData.winddir_avg10m)
                    font.pixelSize: 16
                    color: "#eff0f1"
                }

                Text {
                    text: "Pressure: " + formatPressure(weatherData.baromrelin)
                    font.pixelSize: 16
                    color: "#eff0f1"
                }

                Text {
                    text: "UV Index: " + (weatherData.uv || "--")
                    font.pixelSize: 16
                    color: "#eff0f1"
                }
            }
        }

        Button {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 8
            width: 32
            height: 32
            text: "↻"
            onClicked: fetchWeatherData()
        }

        Text {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 8
            text: lastUpdateTime ? "Updated: " + lastUpdateTime : ""
            color: "#7f8c8d"
            font.pixelSize: 16
            visible: lastUpdateTime !== ""
        }
    }

    Component.onCompleted: {
        loadConfigFromFile()
    }
}
