There are certain details about the test application:
1. In order to do the networking and parse RSS feed Alamofire 3-rd party libraries are used (via CocoaPods).
2. Pattern MVC is aimed with slight modification when data logic is separated into standalone data controllers.
3. There were some comments added within the implementation of methods in places where some peculiarities exist. When I have more time I usually add some more details.
4. Documenting notes were not added except some pretty rare cases due to lack of time I had to implement the test app.
5. Entertainment/environment cells are colored in order to make it clear where is which section.
6. Subtle spinner animation is to the right of segmented control in the navigation bar.
7. Some algorithms in the data processing were simplified due to lack of time.
8. Pods libraries are included into repository because they were not compiling from scratch so required some small adjustments.