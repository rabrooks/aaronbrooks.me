// CloudFront Function — viewer-request.
// Two jobs:
//   1. Redirect www.aaronbrooks.me → aaronbrooks.me (301).
//   2. Rewrite trailing-slash URLs to /index.html so S3 serves the right object.
//
// Pure JS (CloudFront Function runtime), no async/await, no external libs.

function handler(event) {
  var request = event.request;
  var host = request.headers.host && request.headers.host.value;
  var uri = request.uri;

  // (1) Canonicalize host: send www to the apex.
  if (host === 'www.aaronbrooks.me') {
    return {
      statusCode: 301,
      statusDescription: 'Moved Permanently',
      headers: {
        location: { value: 'https://aaronbrooks.me' + uri },
      },
    };
  }

  // (2) Static-site URL rewriting.
  // - "/foo/" -> "/foo/index.html"
  // - "/foo"  -> 301 to "/foo/" (only if it has no file extension)
  // - "/foo.xml" or "/path/file.css" -> pass through.
  if (uri.endsWith('/')) {
    request.uri = uri + 'index.html';
  } else {
    var lastSegment = uri.substring(uri.lastIndexOf('/') + 1);
    if (lastSegment.indexOf('.') === -1) {
      return {
        statusCode: 301,
        statusDescription: 'Moved Permanently',
        headers: {
          location: { value: uri + '/' },
        },
      };
    }
  }

  return request;
}
