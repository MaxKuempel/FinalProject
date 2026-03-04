       let test;
        let csv;

                function FetchTest(){
    fetch("data/ports.csv")
    .then(response => response.text())
    .then(data => {
        csv = data;
        console.log("conversion started");
        test = csv2geojson.auto(data);
        console.log("conversion complete :)");
         DisplayPorts();
         })
        }
FetchTest()

//basemap
var map = L.map('map')
        .setView([20, 0], 3)

var OpenStreetMap_HOT = L.tileLayer('https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png', {
	maxZoom: 19,
	attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Tiles style by <a href="https://www.hotosm.org/" target="_blank">Humanitarian OpenStreetMap Team</a> hosted by <a href="https://openstreetmap.fr/" target="_blank">OpenStreetMap France</a>'
});
OpenStreetMap_HOT.addTo(map);


function DisplayPorts(){
for (let i = 0; i < test.length; i++){

    var circle = L.circle([Number(test[i].Latitude), Number(test[i].Longitude)], //make circle, flip coords
        {
            radius: 100
        }).addTo(map)
};

}




window.onload = function() {
    FetchTest();
}

