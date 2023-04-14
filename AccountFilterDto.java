package com.edsa.factory.api.dtos;

import java.time.OffsetDateTime;
import java.util.Date;

import org.springframework.format.annotation.DateTimeFormat;

import lombok.Data;

@Data
public class AccountFilterDto {
    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
    private OffsetDateTime ifModifiedSince;

    private String searchQuery;
    
    private String fieldOne;
	
	private String fieldTwo;
	
	private Date fieldThreeFrom;
	
	private Date fieldThreeTo;
}