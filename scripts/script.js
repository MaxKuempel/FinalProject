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




function Draw_Line(i, entries){
 new L.Polyline(
        [[Number(entries[i].Dom_Lat), Number(entries[i].Dom_Lon)],
        [Number(entries[i].For_Lat), Number(entries[i].For_Lon)]], //make circle, flip coords
        {
       weight: (entries[i].TONNAGE / 200000)
        }).addTo(lines)
}


let country_selected; 

function DisplayPorts(){
lines.clearLayers();
 country_selected = document.getElementById("country").value
    let Line_To_Display;
Line_To_Display = flows.filter(entry => entry.CTRY_F_NAME === country_selected);
for (let i = 0; i <  Line_To_Display.length; i++){
Draw_Line(i, Line_To_Display)
  
};

};



    FetchFlows();

window.onload = function() {
}

