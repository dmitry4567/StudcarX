var express = require('express');
var app = require('express')();
var server = require('http').Server(app);
var mongoose = require('mongoose');
const bodyParser = require('body-parser');
var io = require('socket.io')(server);
const multer = require("multer");
var fs = require('fs');
const port = process.env.PORT || 5000;

app.use(express.json());
JSON.stringify();
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

const upload = multer({ dest: "uploads" });
app.use(express.static(__dirname));
app.use("/getimages", express.static("uploads"));

var letters1 = /^[A-Za-z]+$/;
var letters2 = /^[А-Яа-я]+$/;

mongoose.connect(
    'mongodb://localhost/mongoose_basics',
    {
        useNewUrlParser: true,
        useUnifiedTopology: true,
    }
)
    .then(() => console.log('run db'))
    .catch(err => console.log(err));

// mongoose.connect(
//     'mongodb+srv://fantastic4567:RtfGw9NA3PRS47n@cluster0.juuoy.mongodb.net/Cluster0?retryWrites=true&w=majority',
//     {
//     useNewUrlParser: true,
//     useUnifiedTopology: true,
//     }
//     )
//     .then(() => console.log('run db'))
//     .catch(err => console.log(err));

const OrderSchema = new mongoose.Schema({
    idd: { type: String, },
    time: { type: String, },
    place: { type: String, },
    route: { type: String, },
    max_people: { type: Number, },
    price: { type: String, },
    time_min: { type: Number, },
    usercreate: { type: String },
    people: { type: Array },
    createdAt: { type: Date, default: Date.now },
});

const UserSchema = new mongoose.Schema({
    username: { type: String, required: true, unique: true },
    login: { type: String, required: true, unique: true },
    firstname: { type: String, required: true },
    secondname: { type: String, required: true },
    password: { type: String, required: true },
});

const GradeSchema = new mongoose.Schema({
    username: { type: String, required: true, unique: true },
    grade_round: { type: Number },
    grade: { type: Array },
});

const List = mongoose.model('List', OrderSchema);
const Users = mongoose.model('Users', UserSchema);
const Grade = mongoose.model('Grade', GradeSchema);


app.post('/reg', (req, res) => {
    if ((req.body.login.match(letters1)) && (req.body.username.match(letters1)) && (req.body.firstname.match(letters2)) && (req.body.secondname.match(letters2))) {
        Users.create({
            username: req.body.username,
            login: req.body.login,
            firstname: req.body.firstname,
            secondname: req.body.secondname,
            password: req.body.password,
        })
            .then(user => {
                Grade.create({
                    username: req.body.username,
                    grade_round: 5,
                    grade: [5]
                })
                res.status(200).json({ message: 'Пользователь создан' + user })
            })
            .catch(err => {
                console.log(err);
                if (err.keyPattern["username"]) { res.status(201).json({ message: 'такой username есть', err: err }) }
                else if (err.keyPattern["login"]) { res.status(202).json({ message: 'такой login есть', err: err }) }
            });
    }
    else {
        console.log("Error");
    }
})

app.post('/login', async (req, res) => {
    try {
        let user = await Users.findOne({
            login: req.body.login
        });
        if (user) {
            if (user.password == req.body.password) {
                Grade.findOne({ username: user.username }, function (err, data) {
                    res.status(200).json({ user, grade: data.grade_round });
                });
            }
            else {
                res.status(201).json({ message: 'it is wrong password :(  ' });
            }
        }
    } catch (e) {
        console.log(e);
    }
})

app.get('/list', async (req, res) => {
    var date = new Date();
    var time_now = date.getHours() * 60 + date.getMinutes();
    List.find({ time_min: { $gte: time_now } }).sort({ time_min: 1 }).exec(function (err, data) {
        res.status(200).send(data);
    });
})

app.post('/get_grade', async (req, res) => {
    Grade.findOne({ username: req.body.username }, function (err, data) {
        res.status(200).json(data.grade_round);
    });
})

app.post('/list_grade', async (req, res) => {
    var date = new Date();
    var time_now = date.getHours() * 60 + date.getMinutes();
    List.find({ time_min: { $lte: time_now }, usercreate: req.body.username }).sort({ time_min: 1 }).exec(function (err, data) {
        res.status(200).send(data);
    });
})

app.post('/update_grade', async (req, res) => {
    console.log(req.body.grade);
    console.log(req.body.people);
    Grade.find({ username: req.body.people }, function (err, data) {
        data = data.reverse();
        //console.log(data);
        for (let i = 0; i < data.length; i++) {
            var sum = 0;
            data[i].grade.push(req.body.grade[i]);
            //console.log(data[i].grade);
            for (let j = 0; j < data[i].grade.length; j++) {
                sum += data[i].grade[j];
            }
            data[i].grade_round = Math.round(sum / data[i].grade.length);
            Grade.updateOne({ username: req.body.people[i] },
                {
                    $push: { grade: req.body.grade[i] },
                    $set: { grade_round: data[i].grade_round }
                },
                function (err, result) {
                });
        }
    });
    List.findOneAndRemove({ idd: req.body.idd }, function (err, d) { })
    res.status(200).json({ message: 'ok' })
})

app.post('/image', upload.single('file'), function (req, res) {
    var tmp_path = req.file.path;
    var target_path = 'uploads/' + req.body.name + '.png';
    var src = fs.createReadStream(tmp_path);
    var dest = fs.createWriteStream(target_path);
    src.pipe(dest);
    src.on('end', function () {
        res.status(200).json({ message: 'ok' })
        fs.unlink(tmp_path, (err) => {
            if (err) throw err;
        });
    });
    src.on('error', function (err) {
        res.status(201).json({ message: 'error' })
    });
});

io.on('connection', function (socket) {
    console.log(socket.id, 'joined');
    app.post('/reg_event', function (req, res) {
        if (req.body.place.match(letters2) && !isNaN(req.body.price)) {
            var choose_time = Number(req.body.time.slice(0, 2)) * 60 + Number(req.body.time.slice(3, 5));
            var date = new Date();
            var time_now = date.getHours() * 60 + date.getMinutes();
            if (choose_time > time_now) {
                List.create({
                    time: req.body.time,
                    place: req.body.place,
                    route: req.body.route,
                    max_people: req.body.max_people,
                    price: req.body.price,
                    time_min: choose_time,
                    usercreate: req.body.usercreate,
                    people: [],
                    idd: mongoose.Types.ObjectId(),
                })
                    .then(user => {
                        res.status(200).json({ message: 'созданно' + user });
                        socket.broadcast.emit("message", "бугагашеньки!");
                    })
                    .catch(err => res.status(201).json({ message: 'уже есть', err: err }));
            }
            else {
                res.status(202).json({ message: 'error time' })
            }
        }
        else {
            console.log("Error");
        }
    })
    app.post('/add', (req, res) => {
        Grade.findOne({ username: req.body.username }, function (err, data) {
            List.updateOne(
                { idd: req.body.idd },
                { $push: { people: { "name": req.body.username, "grade": data.grade_round.toString() } } },
                function (err, result) {
                    res.status(200).json({ message: 'ok' })
                    socket.broadcast.emit("message", "бугагашеньки!");
                }
            );
        });
    })
    app.post('/delevent', function (req, res) {
        List.findOneAndRemove({ idd: req.body.idd }, function (err, d) {
            if (!err) {
                res.status(200).json({ message: "end" })
                socket.broadcast.emit("message", "бугагашеньки!");
            }
        })
    })
    app.post('/deluser', (req, res) => {
        List.updateOne(
            { idd: req.body.idd },
            { $pull: { people: { name: req.body.username } } },
            function (err, result) {
                res.status(200).json({ message: 'del' })
                socket.broadcast.emit("message", "бугагашеньки!");
            }
        )
    })
});

server.listen(9090, () => {
    console.log("start");
});

//25059365ira