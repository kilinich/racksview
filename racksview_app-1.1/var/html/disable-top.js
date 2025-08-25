<script>
document.addEventListener('DOMContentLoaded', function() {
    var header = document.querySelector('h1');
    if (header && header.textContent.trim() === 'Index of /video/') {
        var links = document.querySelectorAll('pre a');
        for (var i = 0; i < links.length; i++) {
            var linkText = links[i].textContent.trim();
            if (linkText === '../') {
                links[i].style.display = 'none';  // Hide ".." at top level to prevent nesting
            } else if (!linkText.endsWith('/')) {
                links[i].target = '_blank';  // Open files in new tab
            }
            // Directory links (ending with '/') stay in iframe for browsing
        }
    }
});
</script>