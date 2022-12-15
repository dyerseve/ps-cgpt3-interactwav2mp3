# Read input string and input filename from command line arguments
$inputString = $args[0]
$inputFilename = $args[1]

# Check if input file exists and can be read
$tryCount = 0
$maxTries = 6
while (!(Test-Path $inputFilename -PathType Leaf) -and $tryCount -lt $maxTries) {
  # Wait 5 seconds
  Start-Sleep -Seconds 5

  # Increment try count
  $tryCount++
}

# Check if input file was successfully read
if ($tryCount -lt $maxTries) {
  # Prompt user to add custom note using dialog box
  $customNote = [System.Windows.Forms.MessageBox]::Show("Add a custom note?", "Custom Note", "YesNo")

  # Check user response
  if ($customNote -eq "Yes") {
    # Prompt for message to join with input string using dialog box
    $message = [System.Windows.Forms.MessageBox]::Show("Enter message to join with input string", "Message", "OK")

    # Use ffmpeg to convert the file from wav to mp3 with custom note and metadata
    ffmpeg.exe -i $inputFilename -metadata comment=$message -vn -ar 44100 -ac 2 -ab 192k -f mp3 $inputString$message.mp3
  } else {
    # Use ffmpeg to convert the file from wav to mp3 without custom note
    ffmpeg.exe -i $inputFilename -vn -ar 44100 -ac 2 -ab 192k -f mp3 $inputString.mp3
  }
} else {
  # Show error message if input file could not be read after 6 tries
  Write-Host "Error: Cannot read input file"

  # Write custom note, input string, and input filename to error log file
  Add-Content -Path "$inputFilename.error.log" -Value "$customNote, $inputString, $inputFilename"
}
