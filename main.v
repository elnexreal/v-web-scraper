import net.http
import net.html
import os
import json

fn main() {
	url := 'https://webscraper.io/test-sites/e-commerce/allinone/computers/laptops'
	output_file := 'output.json'

	req := http.fetch(http.FetchConfig{
		user_agent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/121.0'
		url: url
	}) or { panic(err) }

	mut parsed_html := html.parse(req.body)
	tags := parsed_html.get_tags_by_attribute_value('class', 'col-md-4 col-xl-4 col-lg-4')

	mut data := []map[string]string{}

	for i, tag in tags {
		product_value := tag.children[0].children[0].children[1].children[1].children[0].attributes.values().last()
		price_value := tag.children[0].children[0].children[1].children[0].content
		description_value := tag.children[0].children[0].children[1].children[2].content.replace('&quot',
			'"')
		reviews_value := tag.children[0].children[0].children[2].children[0].content

		data.insert(i, {
			'product':     '${product_value}'
			'price':       '${price_value}'
			'description': '${description_value}'
			'reviews':     '${reviews_value}'
		})
	}

	json_data := json.encode_pretty(data)

	if os.exists(output_file) {
		os.write_file(output_file, json_data) or { panic('Failed to write to the file: ${err}') }
		println('File succesfully written.')
	} else {
		println("File doesn't exists, creating...")
		os.create(output_file) or { panic('Failed to create ${output_file}') }
		println('File created successfully.')
		os.write_file(output_file, json_data) or { panic('Failed to write to the file: ${err}') }
		println('File succesfully written.')
	}
}
