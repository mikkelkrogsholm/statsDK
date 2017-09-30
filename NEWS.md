# statsDK 0.1.0

* This was the first version

# statsDK 0.1.1
* Added a `NEWS.md` file to track changes to the package.
* Changed the package to use the streaming version of the API. This ensures it can collect the very large data sets.
* Changed to using the httr package for retrival in order to ensure proper error messages from the API.
* Added the base_url and language arguments for further flexibility.
* retrieve_data() will fill out missing parameters and setting them to *, which means all data.
* Metada for a table is added to it as an attribute.
* Changed the fix_time() function to work on strings and not data frames. The reason for this was to increase the flexibility in cause of name changes in column names.
