async function classifyImage() {

    const img = document.getElementById('img');

    console.log('Path >>>', img.src);


    // RESULT TO PASS
    let result = [];
    let model, webcam, labelContainer, maxPredictions;

    // LOAD MOBILENET MODEL

    const URL = "https://teachablemachine.withgoogle.com/models/ifsOZ-AVm/";
    const modelURL = URL + "model.json";
    const metadataURL = URL + "metadata.json";
    model = await tmImage.load(modelURL, metadataURL);
    maxPredictions = model.getTotalClasses();
    console.log(maxPredictions);

//    const mobilenet = require('@tensorflow-models/mobilenet');
//    const model = await mobilenet.load();


    // CLASSIFY THE IMAGE
    let predictions = await model.predict(img);
    console.log('Pred >>>', predictions);

//    // Get the logits.
//    const logits = model.infer(img);
//    console.log('Logits');
//    logits.print(true);
//
//    // Get the embedding.
//    const embedding = model.infer(img, true);
//    console.log('Embedding');
//    embedding.print(true);

    // EXTRACTION OF DATA...
    predictions.forEach(function(item, index) {
//         console.log(item);
//         for (let key in item) {
//             console.log(key, item[key]);
//         }
        result.push(item);
    });

    console.log('O/P', result);

//    await faceDetection.send({image: img});

    return result;
}