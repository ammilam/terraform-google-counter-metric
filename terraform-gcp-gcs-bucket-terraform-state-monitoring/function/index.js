'use strict';

exports.state = (file, context) => {

  // get bucket name from env variable
  const bucketName = process.env.bucket
  // creates a new storage client
  const {
    Storage
  } = require('@google-cloud/storage');
  const storage = new Storage();
  console.log('Reading File');
  // console.log(JSON.stringify(file))
  var buf = '';
  // for the file uploaded to the bucket, get file contents
  var a = storage.bucket(bucketName).file(file.name).createReadStream();
  a.on('data', function (d) {
    buf += d;
  }).on('end', function () {
    console.log("End");
    const d = JSON.parse((buf))
    const resources = d.resources
    // for each terraform resoruce
    resources.forEach(resource => {
      const type = resource.type
      const name = resource.name
      const mode = resource.mode
      // log json payload if resource is managed
      if (mode == "managed") {
        const instances = resource.instances
        instances.forEach(instance => {
          const id = instance.attributes.id
          const payload = {
            name: name,
            type: type,
            id: id,
            stateFile: file.name
          }
          console.log(JSON.stringify(payload))
        })
      }

      // skip unmanaged resources
      if (mode != "managed") {
        console.log(`Skiping ${mode} resource: ${type}.${name}`)
      }
    })
  });
};