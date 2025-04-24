  import processing.data.JSONObject;
  import processing.data.JSONArray;
  import java.text.SimpleDateFormat;
  import java.util.Date;

  PImage weather_icon;
  String apiKey = "9cf275fd0d1dd5365b1004c036f92ade";  // Your API key
  String city = "London";  // Default city
  String userCity = city;
  float temperature;
  float wind_speed;
  String weather_descriptions;
  String wind_dir;
  float feelslike;
  float uv_index;
  String todayDate, currentTime;
  String weatherFile = "weatherData.json";
  String location;
  String resultText = "";
  String searchDate = "Enter date";
  String searchTime = "Enter time";
  boolean dateActive = false;
  boolean timeActive = false;
  boolean cityActive = false;

  void setup() {
    size(1000, 600);
    updateWeather();
  }

  void draw() {
    background(255);
    textSize(18);
    fill(0);
    text("Ændre byen: ", 530, 120, 460, height-30);  
    text("Klik på feltet med en by og dermed indtast en ny by.", 530, 160, 460, height-30);
    text("Klik på Update for at opdatere vejret.", 530, 190, 460, height-30);
    text("Søg efter tidligere vejroplysninger:", 530, 230, 460, height-30);
    text("Dato: Klik på Enter date og indtast en dato (f.eks. 2025-03-31).", 530, 270, 460, height-30);
    text("Tid: Klik på Enter time og indtast et tidspunkt (f.eks. 14:30:00).", 530, 320, 460, height-30);
    text("Klik på Search for at få vejroplysninger for den ønskede dato og tid.", 530, 370, 460, height-30);
    text("Weather in " + city, 10, 30);
    text("Date: " + todayDate, 10, 60);
    text("Time: " + currentTime, 10, 90);
    text("Weather Description: " + weather_descriptions, 10, 120);
    text("Temperature: " + temperature + "°C", 10, 150);
    text("Feelslike: " + feelslike + "°C", 10, 180);
    text("Wind speed: " + wind_speed + " km/t", 10, 210);
    text("wind direction: " + wind_dir,  10, 240);
    text("Uv-index: " + uv_index , 10, 270);
    text("Location: " + location, 10, 300);

    if (weather_icon != null) {
        image(weather_icon, 350, 50, 128, 128); 
    }
fill(255);
rect(350, 210, 150, 30);
fill(0);
text(userCity, 360, 230);

fill(200);
rect(350, 250, 100, 30);
fill(0);
text("Update", 370, 270);

// Længere ned (rykket med mindst 60 pixels)
fill(255);
rect(350, 350, 150, 30);  // Flyttet 60 pixels længere ned
fill(0);
text(searchDate, 360, 370);

fill(255);
rect(350, 390, 150, 30);  // Flyttet 60 pixels længere ned
fill(0);
text(searchTime, 360, 410);

fill(200);
rect(350, 430, 100, 30);  // Flyttet 60 pixels længere ned
fill(0);
text("Search", 375, 450);

text("Result:", 10, 470);
text(resultText, 10, 490, 680, 100);
}

void mousePressed() {
    if (mouseX > 350 && mouseX < 500 && mouseY > 210 && mouseY < 240) {
      cityActive = true;
      dateActive = false;
      timeActive = false;
      userCity = "";
    } else if (mouseX > 350 && mouseX < 450 && mouseY > 250 && mouseY < 280) {
      city = userCity;
      updateWeather();
    } else if (mouseX > 350 && mouseX < 500 && mouseY > 350 && mouseY < 380) {
      dateActive = true;
      timeActive = false;
      cityActive = false;
      searchDate = "";
    } else if (mouseX > 350 && mouseX < 500 && mouseY > 390 && mouseY < 420) {
      timeActive = true;
      dateActive = false;
      cityActive = false;
      searchTime = "";
    } else if (mouseX > 350 && mouseX < 450 && mouseY > 430 && mouseY < 460) {
      search();
    } else {
      dateActive = false;
      timeActive = false;
      cityActive = false;
    }
}




  void keyPressed() {
    if (key == CODED && keyCode == SHIFT) {
      return;
    }
    
    if (dateActive) {
      if (key == BACKSPACE && searchDate.length() > 0) {
        searchDate = searchDate.substring(0, searchDate.length() - 1);
      } else if (key != BACKSPACE && key != ENTER) {
        searchDate += key;
      }
    } else if (timeActive) {
      if (key == BACKSPACE && searchTime.length() > 0) {
        searchTime = searchTime.substring(0, searchTime.length() - 1);
      } else if (key != BACKSPACE && key != ENTER) {
        searchTime += key;
      }
    } else if (cityActive) {
      if (key == BACKSPACE && userCity.length() > 0) {
        userCity = userCity.substring(0, userCity.length() - 1);
      } else if (key != BACKSPACE && key != ENTER) {
        userCity += key;
      }
    }
  }




  void updateWeather() {
    todayDate = getTodayDate();
    currentTime = getCurrentTime();
    String url = "http://api.weatherstack.com/current?access_key=" + apiKey + "&query=" + city;
    JSONObject json = loadJSONObject(url);
    
    if (json != null && json.hasKey("current") && json.hasKey("location")) {
      JSONObject current = json.getJSONObject("current");
      JSONObject loc = json.getJSONObject("location");
      
      temperature = current.getFloat("temperature");
      feelslike = current.getFloat("feelslike");
      wind_speed = current.getFloat("wind_speed");
      //wind_dir = current.getString("wind_direction");
      //weather_descriptions = current.getString("weather_description");
      uv_index = current.getFloat("uv_index");
      location = loc.getString("name") + ", " + loc.getString("country");

        JSONArray iconArray = current.getJSONArray("weather_icons");
        String weather_icon_url = "";
        if (iconArray != null && iconArray.size() > 0) {
            weather_icon_url = iconArray.getString(0);
            downloadWeatherIcon(weather_icon_url); // Download og indlæs ikonet
        }

      JSONArray weatherArray = current.getJSONArray("weather_descriptions");
        if (weatherArray != null && weatherArray.size() > 0) {
            weather_descriptions = weatherArray.getString(0);
        } else {
            weather_descriptions = "No description available";
        }

        // Hent wind_dir korrekt
        if (current.hasKey("wind_dir")) {
            wind_dir = current.getString("wind_dir");
        } else {
            wind_dir = "Unknown";
        }
      
      saveWeatherData();
    }
  }

  void saveWeatherData() {
    JSONObject weatherData = loadJSONObject(weatherFile);
    if (weatherData == null) {
      weatherData = new JSONObject();
    }
    if (!weatherData.hasKey(city)) {
      weatherData.setJSONObject(city, new JSONObject());
    }
    
    JSONObject cityData = weatherData.getJSONObject(city);
    if (!cityData.hasKey(todayDate)) {
      cityData.setJSONObject(todayDate, new JSONObject());
    }
    
    JSONObject dailyData = cityData.getJSONObject(todayDate);
    JSONObject entry = new JSONObject();
    entry.setFloat("temperature", temperature);
    entry.setFloat("wind_speed", wind_speed);
    entry.setString("wind_direction", wind_dir);
    entry.setString("weather_decription", weather_descriptions);
    entry.setFloat("uv-index", uv_index);
    entry.setFloat("feelslike", feelslike);
    entry.setString("location", location);
    dailyData.setJSONObject(currentTime, entry);
    saveJSONObject(weatherData, weatherFile);
  }

  void search() {
    resultText = loadNearestWeatherByDateAndLocation(searchDate, searchTime, city);
  }

  String loadNearestWeatherByDateAndLocation(String searchDate, String searchTime, String city) {
    JSONObject weatherData = loadJSONObject(weatherFile);
    
    if (weatherData != null && weatherData.hasKey(city)) {
      JSONObject cityData = weatherData.getJSONObject(city);
      if (cityData.hasKey(searchDate)) {
        JSONObject dailyData = cityData.getJSONObject(searchDate);
        
        if (dailyData.keys().size() > 0) {
          ArrayList<String> times = new ArrayList<String>(dailyData.keys());
          String closestTime = findClosestTime(times, searchTime);
          
          if (closestTime != null && dailyData.hasKey(closestTime)) {
            JSONObject entry = dailyData.getJSONObject(closestTime);
            return "Temp: " + entry.getFloat("temperature") + "°C, Wind: " + entry.getFloat("wind_speed") + " km/t " + " wind_direction:" +  entry.getString("wind_direction") + " weather_descriptions: " + entry.getString("weather_decription") + " UV: " + entry.getFloat("uv_index",uv_index) + " feelslike: " + entry.getFloat("feelslike", feelslike) + (" at " + closestTime );
          }
        }
      }
    }
    
    return "No data found for " + searchDate + " in " + city;
  }


  String getCountryFromCity(String city) {
    String url = "http://api.weatherstack.com/current?access_key=" + apiKey + "&query=" + city;
    JSONObject json = loadJSONObject(url);
    if (json != null && json.hasKey("location")) {
      JSONObject loc = json.getJSONObject("location");
      return loc.getString("country");
    }
    return "Unknown";
  }



  String findClosestTime(ArrayList<String> times, String targetTime) {
    if (times.isEmpty()) return null;
    
    String closestTime = times.get(0);
    int minDifference = Integer.MAX_VALUE;
    int targetSeconds = timeToSeconds(targetTime);
    
    for (String time : times) {
      int timeSeconds = timeToSeconds(time);
      
      if (timeSeconds != -1) {
        int diff = abs(timeSeconds - targetSeconds);
        if (diff < minDifference) {
          minDifference = diff;
          closestTime = time;
        }
      }
    }
    
    return closestTime;
  }

  int timeToSeconds(String time) {
    try {
      String[] parts = time.split(":");
      if (parts.length == 3) {
        return int(parts[0]) * 3600 + int(parts[1]) * 60 + int(parts[2]);
      }
    } catch (Exception e) {
      println("Error parsing time: " + time);
    }
    
    return -1;
  }

  // FIX: Added missing functions
  String getTodayDate() {
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    return sdf.format(new Date());
  }

  String getCurrentTime() {
    SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
    return sdf.format(new Date());
  }

void downloadWeatherIcon(String imageUrl) {
    try {
        byte[] imageBytes = loadBytes(imageUrl); // Hent billedet som byte-array
        if (imageBytes != null) {
            saveBytes("weather_icon.png", imageBytes); // Gem billedet lokalt
            weather_icon = loadImage("weather_icon.png"); // Indlæs billedet
        }
    } catch (Exception e) {
        println("Failed to download weather icon: " + e.getMessage());
    }
}