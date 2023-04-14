package com.edsa.factory.api.dtos;

import java.util.Date;

import jakarta.persistence.Version;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class AccountDto {

	private Long id;

	@Size(max=250)
	@NotEmpty
	private String fieldOne;
	
	@Size(max=250)
	private String fieldTwo;
	
	private Date fieldThree;

	@NotNull
	private boolean enable = true;

	private Integer version;
}
