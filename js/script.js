var FaceDetection = {
  namespace : 'webarbeit',
  userId : null,

  init : function() {
    FaceDetection.userIdDomObj = $('#userId');
    FaceDetection.imageUrlDomObj = $('#imageUrl');
    FaceDetection.messageDomObj = $('#message');
    FaceDetection.faceClient = FaceClientAPI;

    $('#addButton').click($.proxy(FaceDetection.addFace, this));
    $('#recButton').click($.proxy(FaceDetection.recFace, this));
    $('#trainButton').click($.proxy(FaceDetection.trainFace, this));
  },

  //--------------------------------------
  recFace : function() {
    if(!FaceDetection.imageUrlDomObj.val()) return false;
    FaceDetection.showMessage('Sending data to Face.com ... ');
    var opt = { namespace: FaceDetection.namespace, uids: 'all' };
    FaceClientAPI.faces_recognize(FaceDetection.imageUrlDomObj.val(), opt, FaceDetection.recognized);
  },

  recognized : function(url, data) {
    console.log('Rec()', data);
    console.log(data.photos[0].tags[0]);

    if(data.photos[0].tags[0].uids.length == 0) {
      FaceDetection.showMessage('Face recognition failed!');
    } else {
      var users = data.photos[0].tags[0].uids;
      FaceDetection.showMessage('Found: ' + users[0].uid + ' to ' + users[0].confidence + '%');
    }
  },

  //--------------------------------------
  addFace : function() {
    if(!FaceDetection.imageUrlDomObj.val() || !FaceDetection.userIdDomObj.val()) return false;
    FaceDetection.showMessage('Sending data to Face.com ... ');
    FaceDetection.userId = FaceDetection.userIdDomObj.val();
    FaceClientAPI.faces_detect(FaceDetection.imageUrlDomObj.val(), FaceDetection.detect);
  },

  detect : function(url, data) {
      data.photos.forEach(function(photo) {
          var tids = photo.tags[0].tid;
          var label = FaceDetection.userId;
          var uid = label + '@' + FaceDetection.namespace;
          var options = {tids: tids, label: label, uid : uid };
          FaceDetection.saveTag(options);
      });
  },

  saveTag : function(options) {
    FaceDetection.showMessage('Saving tag ... ');
    FaceClientAPI.tags_save(options, FaceDetection.train);
  },

  trainFace : function() {
    console.log('Train()', data);
    var uids = FaceDetection.userId + '@' + FaceDetection.namespace;
    var options = { uids : uids, namespace : FaceDetection.namespace };

    FaceClientAPI.faces_train(options, FaceDetection.finish);
  },

  train : function(data) {
    console.log('Train()', data);
    var uids = FaceDetection.userId + '@' + FaceDetection.namespace;
    var options = { uids : uids, namespace : FaceDetection.namespace };

    FaceClientAPI.faces_train(options, FaceDetection.finish);
  },

  finish : function(data) {
    FaceDetection.showMessage('Face has been saved!');
    console.log('Finish()', data);
  },

  //--------------------------------------
  showMessage : function(msg) {
    FaceDetection.messageDomObj.fadeIn().html(msg);
  },

  hideMessage : function() {
    FaceDetection.messageDomObj.fadeOut().html('');
  },

};
FaceDetection.init();