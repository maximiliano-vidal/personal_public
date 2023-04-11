package com.fwk.arqrestapis.io;

import java.util.Date;
import java.util.HashMap;

import lombok.Data;

@Data
public class DefaultMetadata extends HashMap<String, Object>{

	private Date timestamp = new Date();
	
	public void addPageInfo(PageInfo p) {
		super.put("paginationInfo",p);
	}

	public void addPartialInfo(PartialInfo p) {
		super.put("partialInfo",p);
	}

}
