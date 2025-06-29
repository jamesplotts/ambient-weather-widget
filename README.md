# Ambient Weather Station Widget for KDE Plasma 6

A KDE Plasma 6 widget that displays real-time weather data from your Ambient Weather station.

![Widget Screenshot](screenshots/widget-panel.png)
![Popup Screenshot](screenshots/widget-popup.png)

## Features

- **Panel Integration**: Compact temperature display in your panel with click-to-expand popup
- **Real-time Data**: Direct connection to Ambient Weather API
- **Comprehensive Weather Data**: Temperature, humidity, wind, pressure, UV index
- **Theme Integration**: Follows your Plasma theme colors and styling
- **Error Handling**: Clear error messages and connection testing

## Requirements

- KDE Plasma 6.0 or later
- Qt 6.0 or later
- Active internet connection
- Ambient Weather station with API access

## Installation

1. Download all the widget files to a directory

2. Create the widget directory structure:
```bash
mkdir -p ~/.local/share/plasma/plasmoids/org.kde.plasma.ambientweather/contents/ui
```

3. Copy the files:
```bash
# Copy main widget file
cp main.qml ~/.local/share/plasma/plasmoids/org.kde.plasma.ambientweather/contents/ui/

# Copy metadata
cp metadata.json ~/.local/share/plasma/plasmoids/org.kde.plasma.ambientweather/
```

4. Restart Plasma:
```bash
plasmashell --replace &
```

## Configuration

### Getting Ambient Weather API Credentials

1. **Create an Account**: Go to [ambientweather.net](https://ambientweather.net) and log into your account
2. **Access API Settings**: Navigate to Account → API Keys  
3. **Generate Keys**: 
   - Create an **API Key** 
   - Create an **Application Key**
   - Note your weather station's **MAC Address** from the device list

### Widget Configuration

1. **Create configuration file**:
```bash
nano ~/.local/share/plasma/plasmoids/org.kde.plasma.ambientweather/apiconfig.txt
```
     
2. **Add your Credentials**:
```
aapiKey=YOUR_API_KEY_HERE
applicationKey=YOUR_APPLICATION_KEY_HERE
macAddress=YOUR_MAC_ADDRESS_HERE
```
   
3. **Save configuration file**:
   - Use Ctrl-X to exit, select Yes to save.  
4. **Add Widget**: Right-click on desktop/panel → Add Widgets → Search "Ambient Weather"

## Usage

### Panel Icon
- Shows current outdoor temperature
- Hover for basic weather info tooltip
- Click to open detailed weather popup

### Popup Panel
Shows weather data including:
- Current temperature and "feels like" temperature
- Humidity and barometric pressure  
- Wind speed and direction
- UV index
- Last update time

## Troubleshooting

### Widget Not Appearing
- Restart Plasma: `plasmashell --replace &`
- Check installation path: `~/.local/share/plasma/plasmoids/`
- Verify file permissions

### API Connection Issues
- Verify API credentials in Ambient Weather account
- Check internet connection
- Ensure MAC address is correct (no colons or dashes)

### Data Not Updating
- Verify API rate limits (Ambient Weather allows 1 call per second, 288 calls per day)
- Check network connectivity

### Common Error Messages
- **"Missing API credentials"**: Enter API keys and MAC address in configuration
- **"API Error: 401"**: Invalid API credentials  
- **"API Error: 404"**: Device not found, check MAC address
- **"API Error: 429"**: Exceeded API rate limit
- **"No data received"**: Device may be offline or not reporting

## File Structure

```
org.kde.plasma.ambientweather/
├── metadata.json              # Widget metadata and information
├── contents/
│   ├── ui/
│   │   └── main.qml          # Main widget implementation
```

## Development

### Building from Source
1. Clone the repository
2. Modify the QML files as needed
3. Test using `plasmoidviewer`:
```bash
plasmoidviewer -a /path/to/widget/directory
```

### Contributing
- Report bugs via GitHub issues
- Submit pull requests for improvements
- Follow KDE development guidelines
- Test on Plasma 6.0+

## License

GPL-2.0 - See LICENSE file for details

## Support

- **Issues**: Report bugs and feature requests on GitHub
- **Documentation**: KDE Plasma widget development docs
- **Community**: KDE community forums and chat

## Changelog

### Version 1.0.0
- Initial release
- Panel integration with popup
- Full Ambient Weather API support
- Theme integration and error handling
