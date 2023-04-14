package com.edsa.factory.model.filters;

import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.util.StringUtils;

import com.edsa.factory.model.entities.Account;
import com.fwk.arqrestapis.repository.FiltersSpecification;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AccountFilter extends FiltersSpecification<Account> {

    private String searchQuery;

	private String fieldOne;
	
	private String fieldTwo;
	
	private Date fieldThreeFrom;
	
	private Date fieldThreeTo;
	    
    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
    private OffsetDateTime ifModifiedSince;

    private boolean includeDeleted = false;

    @Override
    public Predicate toPredicate(Root<Account> root, CriteriaQuery<?> query, CriteriaBuilder criteriaBuilder) {
    	List<Predicate> restrictions = new ArrayList<>(); 
		
		if (StringUtils.hasText(searchQuery)) {
			String searchQueryLike = new StringBuilder().append("%").append(searchQuery).append("%").toString();
			restrictions.add(
					criteriaBuilder.or(
						criteriaBuilder.like(root.get("fieldOne"), searchQueryLike),
                        criteriaBuilder.like(root.get("fieldTwo"), searchQueryLike)
					)	
			);
		}
		
		if (getFieldOne()!= null && !getFieldOne().isEmpty() ) {
			restrictions.add(criteriaBuilder.like(root.get("fieldOne"), getFieldOne()));	
		}
		if (getFieldTwo()!= null && !getFieldTwo().isEmpty() ) {
			restrictions.add(criteriaBuilder.like(root.get("fieldTwo"), getFieldTwo()));	
		}
		if (getFieldThreeFrom() != null) {
			restrictions.add(criteriaBuilder.greaterThanOrEqualTo(root.get("fieldThree"),getFieldThreeFrom()));
		}
		if (getFieldThreeTo() != null) {
			restrictions.add(criteriaBuilder.lessThanOrEqualTo(root.get("fieldThree"),getFieldThreeTo()));
		}
		if (getFieldThreeTo() != null) {
			restrictions.add(criteriaBuilder.lessThanOrEqualTo(root.get("fieldThree"),getFieldThreeTo()));
		}
		
		if (ifModifiedSince != null) {
			restrictions.add(criteriaBuilder.or(
                    criteriaBuilder.greaterThan(root.get("lastModifiedDate"), ifModifiedSince),
                    criteriaBuilder.and(
                    	criteriaBuilder.isNull(root.get("lastModifiedDate")),
                		criteriaBuilder.greaterThan(root.get("createdDate"), ifModifiedSince)
                    )
            ));
		}
		
		if (!includeDeleted) {
			restrictions.add(criteriaBuilder.isNull(root.get("deletedDate")));
		}
		
		return criteriaBuilder.and(restrictions.toArray(new Predicate[restrictions.size()])); 
    }

}

