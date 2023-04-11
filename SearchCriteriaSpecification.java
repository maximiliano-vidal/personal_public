package com.fwk.arqrestapis.repository;

import org.springframework.data.jpa.domain.Specification;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Data
public abstract class SearchCriteriaSpecification<T> implements Specification<T> {

	private String searchQuery;
}
