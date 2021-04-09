const mongoose = require('mongoose');
var userSchema = new mongoose.Schema({
    email: {
        type: String,
        unique: true,
    },
    latitude: String,
    longitude: String,
    time: String,
    victims:String,
    endRide: String
});
module.exports = mongoose.model('User',userSchema);