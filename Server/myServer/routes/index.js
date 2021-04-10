var express = require('express');
var router = express.Router();
const user= require('../models/userSchema');
const rider=require('../models/riderSchema');
const noNetwork=require('../models/noNetworkSchema');
const { use } = require('../app');
const { json } = require('express');
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

router.get('/user/:email/:latitude/:longitude', function(req, res, next) {
  var email=req.params.email,
      latitude=req.params.latitude,
      longitude=req.params.longitude;
  console.log("user called by "+email+" with "+latitude+" "+longitude);
  user.findOne({email: email},async(err,User)=>{
    if(User==null){
      User=new user({
        email:email,
        latitude:latitude,
        longitude:longitude,
        time:getDateTime(),
        victims:"-"
      });
    }
    else{
      User.latitude=latitude;
      User.longitude=longitude;
      User.time=getDateTime();
    }
    res.send(User.victims);
    User.victims="-";
    await User.save(function(err){
      if (err) return console.error(err);
    });
  });
});

router.get('/rider/:email', function(req, res, next){
  var email=req.params.email;
  console.log("rider called by "+email);
  rider.findOne({email: email},async(err,User)=>{
    if(User==null){
      User=new rider({
        email:email,
        pinged:"1",
      });
    }
    else{
      User.pinged="1";
    }
    await User.save(function(err){
      if (err) return console.error(err);
    });
  });
  res.send("-");
});

router.get('/endRide/:email', function(req, res, next) {
  var email=req.params.email;
  console.log("endRide called by "+email);
  rider.remove({email:email},async(err,User)=>{
  if(err){
    console.log(err);
  }
  if(User){
    console.log("rider removed");
  }
  else{
    console.log("no rider to remove");
  }
 });
 res.send("-");
});

router.get('/alert/:email', function(req, res, next){
  var email=req.params.email;
  var lat,lon,em;
  var temp_email="-";
  user.findOne({email: email},async(err,User)=>{
    lat=User.latitude;
    lon=User.longitude;
    em=User.email;
    console.log("alert called by "+email);
    user.find({},function(err,users){
      const max=10000000007;
      console.log("live users :"+users.length);
      for (i = 0; i < users.length; i++) {
        var t_lat=users[i].latitude;
        var t_lon=users[i].longitude;
        console.log(users[i].email);
        if((t_lat-lat)*(t_lat-lat)+(t_lon-lon)*(t_lon-lon)<max){
          temp_email=users[i].email;
        }
      }
      console.log("closest person "+ temp_email);
      user.findOne({email: temp_email},async(err,User)=>{
        User.victims=em;
        await User.save();
        rider.remove({email:email},async(err,User)=>{
            if(err){
              console.log(err);
            }
            if(User){
              console.log("rider removed");
            }
            else{
              console.log("no rider to remove");
            }
         });
      });   
    });
  });
  res.send("-");
});

router.get('/getLocation/:email',function(req, res, next){
  var email=req.params.email;
  user.findOne({email: email},async(err,User)=>{
    res.send(User.latitude+" "+User.longitude+" "+User.time);
  });
});

router.get('/addNoNetworkPoint/:lat1/:lon1/:lat2/:lon2',function(req, res, next){
  res.send("");
  var lat1=req.params.lat1;
  var lon1=req.params.lon1;
  var lat2=req.params.lat2;
  var lon2=req.params.lon2;
  var tuple=new noNetwork({
    latitude1: lat1,
    longitude1: lon1,
    latitude2: lat2,
    longitude2: lon2
  });
  tuple.save();
});

function getDateTime(){
  var now     = new Date(); 
  var year    = now.getFullYear();
  var month   = now.getMonth()+1; 
  var day     = now.getDate();
  var hour    = now.getHours();
  var minute  = now.getMinutes();
  var second  = now.getSeconds(); 
  if(month.toString().length == 1) {
       month = '0'+month;
  }
  if(day.toString().length == 1) {
       day = '0'+day;
  }
  if(hour.toString().length == 1) {
       hour = '0'+hour;
  }
  if(minute.toString().length == 1) {
       minute = '0'+minute;
  }
  if(second.toString().length == 1) {
       second = '0'+second;
  }   
  var dateTime = hour+':'+minute+':'+second+' '+day+'/'+month+'/'+year;   
   return dateTime;
}
module.exports = router;
