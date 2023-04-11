package com.fwk.arqrestapis.io;

import java.util.List;

import org.springframework.data.domain.Page;

public class PagedResult<T> extends Response<List<T>> {
	
	public static <T> PagedResult<T> of(Page<T> page) {
		PagedResult<T> result = new PagedResult<T>();
		result.setData(page.getContent());
		result.getMetadata().addPageInfo(PageInfo.of(page));
		return result;
	}
	
}
