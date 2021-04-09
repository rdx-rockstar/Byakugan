const mongoose = require('mongoose');
var ridingUserSchema = new mongoose.Schema({
    email: {
        type: String,
        unique: true,
    },
    pinged: String
});
module.exports = mongoose.model('RidingUser',ridingUserSchema);
