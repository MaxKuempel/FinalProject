let flows;
let csv;
let countries;

function FetchCountries(){
    fetch("data/WorldCountries_50m.geojson")
    .then(response => response.json())
    .then(data => {
        countries = data;
        console.log(data);
        DisplayCountries()
    })
}

function FetchFlows(Year, Import_Export){
    let datasetname = "data/" + Import_Export + "_" + Year + "_merged.csv"
    console.log(datasetname)
    fetch(datasetname)
    .then(response => response.text())
    .then(data => {
        csv = data;
        console.log("conversion started");
        flows = csv2geojson.auto(data);
        console.log("conversion complete :)");
        
         DisplayPorts();
         })
                    }


//basemap
var map = L.map('map')
        .setView([20, 0], 3)

var OpenStreetMap_HOT = L.tileLayer('https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png', {
	maxZoom: 19,
    maxBounds: L.latLngBounds(L.latLng(60,0),L.latLng(-60,10)),
    maxBoundsViscosity: 1.0,
	attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Tiles style by <a href="https://www.hotosm.org/" target="_blank">Humanitarian OpenStreetMap Team</a> hosted by <a href="https://openstreetmap.fr/" target="_blank">OpenStreetMap France</a>'
});
OpenStreetMap_HOT.addTo(map);

//displaying countries
function DisplayCountries() {
    L.geoJson(countries, 
        {
        fillOpacity: 0,
        color: "#000",
        weight: 1.1,
        opacity: 1

    })
    
    .addTo(map)
}

map.on('click', function(e) {
    console.log(e.latlng)
    for (let i = 0; i < countries.features.length; i++) {
    if (turf.booleanPointInPolygon(
        [e.latlng.lng,
        e.latlng.lat
        ], 
        countries.features[i])) {
            DisplayPorts(countries.features[i].properties.admin)
        }
        
    }
    
})



//RENDERING LINES
var lines = L.layerGroup().addTo(map); // declare layer group




function ColorLines(category) {
    switch (category) {
        case "Industrial goods":
            return "#f8e16f"
        case "Agricultural goods":
            return "#70b070"
        case "Ore, Rock and Minerals":
            return "#f4895f"
        case  "Wood and Wood Products":
            return "#6c584c"
        case "Coal, Oil, and Petrochemicals":
            return "#333333"
        case "Fish and Marine Goods": 
            return "#369acc"
        case "Other Goods":
            return "#9656a2"
    }
}

function LinePopup(line){
    if (line.TYPE_PROC == "Export") {
        return (
            "In " + line.YEAR + ", " +
            Math.round(line.TONNAGE).toLocaleString() + " tons of " +
            line.Good_Category + " was exported from " +
            line.PORT_NAME + " to " + line.FORPORT_NAME + ", " +
            line.CTRY_F_NAME + ". " +
            "\n Specific good: " + line.PMS_NAME
        )
    }
    else {
        return (
             "In " + line.YEAR + ", " +
            Math.round(line.TONNAGE).toLocaleString() + " tons of " +
            line.Good_Category + " was imported to " +
            line.PORT_NAME + " from " + line.FORPORT_NAME + ", " +
            line.CTRY_F_NAME + ". " +
            "\n Specific good: " + line.PMS_NAME
        )
    }
}

function Draw_Line(i, entries, maxFlow){
 new L.Polyline(
        [[Number(entries[i].Dom_Lat), Number(entries[i].Dom_Lon)],
        [Number(entries[i].For_Lat), Number(entries[i].For_Lon)]], //make circle, flip coords
        {
            color: ColorLines(entries[i].Good_Category),
       weight: ((entries[i].TONNAGE / maxFlow) * 10)
        }).bindPopup(
            LinePopup(entries[i])

        ).addTo(lines)
}

//Legend
//-------------------------
var legend = L.control({position: 'bottomright'});

legend.onAdd = function (map) {
    var div = L.DomUtil.create('div', 'info legend');
    // Further HTML will be added here
    return div;
};
                              
legend.onAdd = function (map) {
    var div = L.DomUtil.create('div', 'info legend'); //stolen and modified from google ai overview
     // Example line thicknesses
    var labels = ["Industrial goods", 
        "Agricultural goods", 
        "Ore, Rock and Minerals",
        "Wood and Wood Products",
        "Coal, Oil, and Petrochemicals",
        "Fish and Marine Goods",
        "Other Goods"

    ];

    // Loop through the thicknesses and generate a label with a line for each
    div.innerHTML = '<h3> Legend </h1>'
    for (var i = 0; i < labels.length; i++) {
        // Add a horizontal line and its corresponding label
        div.innerHTML +=
            labels[i] + '<br>' +
            '<i style="border-top: ' + 5 + 'px solid ' + ColorLines(labels[i]) + ';"></i> '  // Custom line style
            labels[i] + '<br>';
    }
    return div;
};
legend.addTo(map);

///---------------
let country_selected; 

function DisplayPorts(country_selected){


lines.clearLayers();
 //country_selected = document.getElementById("country").value
    let Line_To_Display;
Line_To_Display = flows.filter(entry => entry.CTRY_F_NAME === country_selected);
for (let i = 0; i <  Line_To_Display.length; i++){
Draw_Line(i, Line_To_Display, Math.max(...Line_To_Display.map(onj => Number(onj.TONNAGE))))


};


};

function FlowSwitcher(){
    direction = document.querySelector('input[name="direction"]:checked') //google ai overvierw
    FetchFlows(document.getElementById('year_slider').value, direction.value)
}
FlowSwitcher()
window.onload = function() {
    FetchCountries()
}

