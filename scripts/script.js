let flows;
let csv;

function FetchFlows(){
    fetch("data/e_2023_merged.csv")
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
	attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Tiles style by <a href="https://www.hotosm.org/" target="_blank">Humanitarian OpenStreetMap Team</a> hosted by <a href="https://openstreetmap.fr/" target="_blank">OpenStreetMap France</a>'
});
OpenStreetMap_HOT.addTo(map);

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

function Draw_Line(i, entries, maxFlow){
 new L.Polyline(
        [[Number(entries[i].Dom_Lat), Number(entries[i].Dom_Lon)],
        [Number(entries[i].For_Lat), Number(entries[i].For_Lon)]], //make circle, flip coords
        {
            color: ColorLines(entries[i].Good_Category),
       weight: ((entries[i].TONNAGE / maxFlow) * 10)
        }).addTo(lines)
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
    var div = L.DomUtil.create('div', 'info legend');
    var thicknesses = [1, 3, 5]; // Example line thicknesses
    var labels = ['Thin Line', 'Medium Line', 'Thick Line'];

    // Loop through the thicknesses and generate a label with a line for each
    for (var i = 0; i < thicknesses.length; i++) {
        // Add a horizontal line and its corresponding label
        div.innerHTML +=
            '<i style="border-top: ' + thicknesses[i] + 'px solid #333;"></i> ' + // Custom line style
            labels[i] + '<br>';
    }
    return div;
};
legend.addTo(map);

///---------------
let country_selected; 

function DisplayPorts(){
lines.clearLayers();
 country_selected = document.getElementById("country").value
    let Line_To_Display;
Line_To_Display = flows.filter(entry => entry.CTRY_F_NAME === country_selected);
for (let i = 0; i <  Line_To_Display.length; i++){
Draw_Line(i, Line_To_Display, Math.max(...Line_To_Display.map(onj => Number(onj.TONNAGE))))
  
};

};



    FetchFlows();

window.onload = function() {
}

