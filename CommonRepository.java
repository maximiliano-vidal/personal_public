package com.fwk.arqrestapis.repository;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.NoRepositoryBean;

@NoRepositoryBean
public interface CommonRepository<T,I> extends JpaRepository<T, I> {
	
	/*Search methods*/
	public Page<T> findBySearchQuery(SearchCriteriaSpecification<T> spec, Pageable pageable);
	public List<T> findBySearchQuery(SearchCriteriaSpecification<T> spec, Sort sort);
	public List<T> findBySearchQuery(SearchCriteriaSpecification<T> spec);
	
	/*Filter methods*/
	public Page<T> findByFilters(FiltersSpecification<T> spec, Pageable pageable);
	public List<T> findByFilters(FiltersSpecification<T> spec, Sort sort);
	public List<T> findByFilters(FiltersSpecification<T> spec);
	
	/*Entity Manager methods*/
	void detach(T attached);
	void clear(T attached);
}

