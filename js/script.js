var FaceDetection = {
  namespace : 'webarbeit',
  userId : null,

  init : function() {
    FaceDetection.userIdDomObj = $('userId');
    FaceDetection.imageUrlDomObj = $('imageUrl');
    FaceDetection.faceClient = FaceClientAPI;

    $('#addButton').click($.proxy(FaceDetection.addFace, this));
    $('#recButton').click($.proxy(FaceDetection.recFace, this));
  },

  recFace : function() {
    if(!FaceDetection.imageUrlDomObj.val()) return false;
    var opt = { namespace: FaceDetection.namespace, uids: 'all' };
    FaceClientAPI.faces_recognize(FaceDetection.imageUrlDomObj.val(), opt, FaceDetection.recognized);
  },

  recognized : function(url, data) {
    console.log('Rec()', data);
  },

  addFace : function() {
    if(!FaceDetection.imageUrlDomObj.val() || !FaceDetection.userIdDomObj.val()) return false;
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
    FaceClientAPI.tags_save(options, FaceDetection.train);
  },

  train : function(data) {
    console.log('Train()', data);
    var uids = FaceDetection.userId + '@' + FaceDetection.namespace;
    var options = { uids : uids, namespace : FaceDetection.namespace };

    FaceClientAPI.faces_train(options, FaceDetection.finish);
  },

  finish : function(data) {
    console.log('Finish()', data);
  },

};
FaceDetection.init();