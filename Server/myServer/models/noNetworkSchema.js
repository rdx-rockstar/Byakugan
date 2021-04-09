const mongoose = require('mongoose');
var ridingUserSchema = new mongoose.Schema({
    latitude1: String,
    longitude1: String,
    latitude2: String,
    longitude2: String
});
module.exports = mongoose.model('noNetworkPoint',ridingUserSchema);
