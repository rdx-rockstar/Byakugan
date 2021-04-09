var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
var mongoose = require('mongoose');
const user= require('./models/userSchema');
const rider=require('./models/riderSchema');
var indexRouter = require('./routes/index');

var app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

mongoose.connect('mongodb://localhost:27017/womenSafety', {useNewUrlParser: true, useUnifiedTopology: true});
const connect = mongoose.connection;
connect.on('open',() => {
  console.log('Connected..');
});

app.use('/', indexRouter);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

//timer

var myVar = setInterval(myTimer, 20*1000);
function myTimer() {
  console.log("timer to check riders");
  rider.find({},function(err,users){
    for (i = 0; i < users.length; i++) {
      if(users[i].pinged=='0'){
        alertCall(users[i].email);
        rider.deleteOne({email:users[i].email},async(err,User)=>{
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
      }
      else{
        users[i].pinged='0';
        users[i].save();
      }
    }   
  });
}

function alertCall(email){
  var lat,lon;
  var temp_email="";
  user.findOne({email: email},async(err,User)=>{
    lat=User.latitude;
    lon=User.longitude;
    user.find({},function(err,users){
      const max=10000000007;
      console.log("live users :"+users.length);
      for (i = 0; i < users.length; i++) {
        var t_lat=users[i].latitude;
        var t_lon=users[i].longitude;
        if((t_lat-lat)*(t_lat-lat)+(t_lon-lon)*(t_lon-lon)<max){
          temp_email=users[i].email;
        }
      } 
      console.log("closest user "+temp_email);
      user.findOne({email: temp_email},async(err,User)=>{
          User.victims=email;
          await User.save();
      });
    });
  });
}

function clearTimer(){
  clearInterval(myVar);
}

module.exports = app;
