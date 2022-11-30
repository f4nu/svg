class Vertex {
    v1;
    v2;
    v3;

    constructor(v1, v2, v3) {
        this.v1 = v1;
        this.v2 = v2;
        this.v3 = v3;
    }
}

vertices = [];
lineLength = 5;
oneRatio = 1;
halfRatio = 0.5;
lines = [];

var currentI = 0;
var currentJ = 0;
var cubeDistanceX = lineLength * oneRatio * 2 + 10;
var cubeDistanceY = lineLength * oneRatio * 2 + 3;
var inc = 0;
var xOffset = 0;
var yOffset = 0;

function setup() {

    var v000 = new Vertex(0, 0, 0);
    var v001 = new Vertex(0, 0, 1);
    var v010 = new Vertex(0, 1, 0);
    var v011 = new Vertex(0, 1, 1);
    var v100 = new Vertex(1, 0, 0);
    var v101 = new Vertex(1, 0, 1);
    var v110 = new Vertex(1, 1, 0);
    var v111 = new Vertex(1, 1, 1);

    lines = [
        [v000, v100],
        [v000, v010],
        [v000, v001],

        [v001, v101],
        [v001, v011],

        [v010, v011],

        [v011, v111],

        [v100, v110],

        [v101, v100],
        [v101, v111],

        [v110, v111],
        [v110, v010],
    ];
}

function draw() {
    var combinations = [];
    for (var b = 1; b <= 4095; b++) {

        combinations.push(
            [
                b & 0b000000000001, // 1
                b & 0b000000000010, // 2
                b & 0b000000000100, // 8
                b & 0b000000001000, // 16
                b & 0b000000010000, // 32
                b & 0b000000100000, // 64
                b & 0b000001000000, // 128
                b & 0b000010000000, // 256
                b & 0b000100000000, // 512
                b & 0b001000000000, // 1024
                b & 0b010000000000, // 2048
                b & 0b100000000000, // 4096
            ]
        )
    }

    var cubes = [];

    console.log(`<svg xmlns="http://www.w3.org/2000/svg" height="4597mm" width="210mm">\n\t<g fill="white" stroke="black" stroke-width="1">`);
    combinations.forEach(function (combination) {
        resetPos();
        const cube = lines.filter((line, i) => !!combination[i]);
        cubes.push(cube);
    });

    cubes = cubes.sort((a, b) => a.length - b.length);

    cubes.splice(0, 1365 + 1365);
    cubes.splice(1365);

    cubes.forEach(function (cube) {
        resetPos();
        drawCube(cube);
        currentJ += 1;
    });

    console.log(`\t</g>\n</svg>`);
}

function drawCube(vertices) {
    console.log(`\t\t<g transform="translate(${xOffset} ${yOffset})">`);
    vertices.forEach(vertices => drawFromVertices(vertices[0], vertices[1]));
    console.log(`\t\t</g>`);
}

function drawFromVertices(vertexA, vertexB) {
    v1a = vertexA.v1;
    v2a = vertexA.v2;
    v3a = vertexA.v3;
    v1b = vertexB.v1;
    v2b = vertexB.v2;
    v3b = vertexB.v3;

    xAModifier = 0;
    yAModifier = 0;
    xBModifier = 0;
    yBModifier = 0;

    if (v1a === 1) {
        xAModifier += oneRatio;
        yAModifier += halfRatio;
    }
    if (v2a === 1) {
        yAModifier -= oneRatio;
    }
    if (v3a === 1) {
        xAModifier -= oneRatio;
        yAModifier += halfRatio;
    }

    if (v1b === 1) {
        xBModifier += oneRatio;
        yBModifier += halfRatio;
    }
    if (v2b === 1) {
        yBModifier -= oneRatio;
    }
    if (v3b === 1) {
        xBModifier -= oneRatio;
        yBModifier += halfRatio;
    }

    xA = xAModifier * lineLength;
    yA = yAModifier * lineLength;

    xB = xBModifier * lineLength;
    yB = yBModifier * lineLength;

    //line(xA, yA, xB, yB);
    console.log(`\t\t\t<line x1="${xA}" y1="${yA}" x2="${xB}" y2="${yB}" />`);
}

function resetPos() {
    if (currentJ >= 21) {
        currentJ = 0;
        currentI++;
    }
    xOffset = cubeDistanceX + cubeDistanceX * (currentJ) * oneRatio;
    yOffset = cubeDistanceY + cubeDistanceY * currentI * oneRatio;
}

setup();
draw();