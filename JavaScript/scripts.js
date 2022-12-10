let getLocationButton = document.getElementById("getLocationButton");

/**
 * Adds functionality to location button.
 * Retrieves current lat/long positions using geolocation.
 */
getLocationButton.addEventListener("click", () => {
  loader.style.display = 'block';
  navigator.geolocation.getCurrentPosition((position) => {
    let lat = position.coords.latitude;
    let long = position.coords.longitude;

    getWeatherData(lat, long);
    getAirData(lat, long);
    getForcastedWeatherData(lat, long);
  });
});

var requestOptions = {
  method: "GET",
  redirect: "follow",
};
const air_pollution = {1: 'Good', 2: 'Fair', 3: 'Moderate', 4: 'Poor', 5: 'Very Poor'};

/**
 * Fetches Open Weather Data API.
 * @param {string} latitude - Current latitude.
 * @param {string} longitude - Current longitude.
 */
async function getWeatherData(latitude, longitude) {
  const response = await fetch(
    `https://api.openweathermap.org/data/2.5/weather?lat=${latitude}&lon=${longitude}&appid=d06a9609b0ee35306540ff68d26c6f51`,
    requestOptions
  );
  var data = await response.json();
  console.log(data); // Use this to explore the API response
  
  displayCurrentData(data);
  loader.style.display = 'none';
}

async function getAirData(latitude, longitude) {
  const response = await fetch(
    `http://api.openweathermap.org/data/2.5/air_pollution?lat=${latitude}&lon=${longitude}&appid=d06a9609b0ee35306540ff68d26c6f51`,
    requestOptions
  );
  var data = await response.json();
  console.log(data); // Use this to explore the API response

  displayAirData(data);
  loader.style.display = 'none';
}

async function getForcastedWeatherData(latitude, longitude) {
  const response = await fetch(
    `https://api.openweathermap.org/data/2.5/forecast?lat=${latitude}&lon=${longitude}&appid=d06a9609b0ee35306540ff68d26c6f51`,
    requestOptions
  );
  var data = await response.json();
  console.log(data); // Use this to explore the API response

  displayForcastedData(data);
  loader.style.display = 'none';
}

/**
 * Displays the weather data via HTML.
 * @param {object} data - Open Weather Data API JSON response.
 */
function displayCurrentData(data) {
  var cityName = data.name;
  var wind = data.wind.speed;
  var icon = data.weather[0].icon;

  document.getElementById("city").innerHTML = cityName;
  document.getElementById("temp").innerHTML = convertToFahrenheit(
    data.main.temp) + ' / ' + convertToC(data.main.temp);
  document.getElementById("wind").innerHTML = 'Wind: ' + wind + ' meter/sec';
  document.getElementById(
    "icon"
  ).src = `http://openweathermap.org/img/wn/${icon}@2x.png`;
}

function displayAirData(data) {
  var aqi = data.list[0].main.aqi;
  document.getElementById("aqi").innerHTML = 'AQI (Air Quality Index): ' + aqi + ', ' + air_pollution[aqi];
}

/**
 * Displays the weather data via HTML.
 * @param {object} data - Open Weather Data API JSON response.
 */
function displayForcastedData(data) {
  var icon = data.list[0].weather[0].icon;

  document.getElementById("forcasted").innerHTML = 'Forecasted weather in 3 hours:'
  document.getElementById("forcasted").style.font = "italic 15px arial,serif";
  document.getElementById("temp_forcasted").innerHTML = convertToFahrenheit(
    data.list[0].main.temp) + ' / ' + convertToC(data.list[0].main.temp);
  document.getElementById(
    "icon_forcasted"
  ).src = `http://openweathermap.org/img/wn/${icon}@2x.png`;
}



/**
 * Converts Kelvin to Fahrenheit temperature scale.
 * @param {string} temp - The title of the book.
 * @returns {string} Current temperature in Fahrenheit.
 */
function convertToFahrenheit(temp) {
  return Math.trunc((temp - 273.15) * 1.8 + 32) + "&deg; F";
}

function convertToC(temp) {
  return Math.trunc(temp - 273.15) + "&deg; C";
}


function visitPage(){
  window.location='https://openweathermap.org/weathermap?basemap=map&cities=false&layer=clouds&lat=30&lon=-20&zoom=3';
}
