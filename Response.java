package com.fwk.arqrestapis.io;

import lombok.AllArgsConstructor;
import lombok.Data;

@AllArgsConstructor
@Data
public class Response<D> {

	private DefaultMetadata metadata;
	private D data;

	public Response() {
		metadata = new DefaultMetadata();
	}
	
	public Response(D data) {
		metadata = new DefaultMetadata();
		this.data = data;
	}
	
}
